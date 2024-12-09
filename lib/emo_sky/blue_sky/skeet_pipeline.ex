defmodule EmoSky.BlueSky.SkeetPipeline do
  use Broadway
  require Logger

  alias Broadway.Message
  alias EmoSky.BlueSky.SkeetProducer

  def start_link(_opts) do
    {:ok, model_info} =
      Bumblebee.load_model({:hf, "finiteautomata/bertweet-base-sentiment-analysis"})

    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "vinai/bertweet-base"})

    # Prepare the serving function
    text_checker =
      Bumblebee.Text.text_classification(model_info, tokenizer,
        compile: [batch_size: 1, sequence_length: 100],
        defn_options: [compiler: EXLA]
      )

    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {SkeetProducer, []},
        transformer: {__MODULE__, :transform, []},
        concurrency: 1
      ],
      processors: [
        default: [
          concurrency: 1
        ]
      ],
      context: %{text_checker: text_checker}
    )
  end

  def transform(event, _options) do
    %Message{
      data: event,
      acknowledger: {__MODULE__, :skeet, []}
    }
  end

  def ack(:skeet, _successful, _failed) do
    :ok
  end

  @impl true
  def handle_message(
        :default,
        %{data: %{"commit" => %{"cid" => cid, "record" => %{"text" => text}}}} = message,
        %{text_checker: text_checker}
      ) do
    %{predictions: [%{label: mood} | _]} = Nx.Serving.run(text_checker, text)
    Phoenix.PubSub.broadcast(EmoSky.PubSub, "skeets", %{id: cid, mood: mood, text: text})

    message
  end
end
