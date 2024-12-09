defmodule EmoSky.BlueSky.SkeetProducer do
  use GenStage
  require Logger

  alias EmoSky.BlueSky.SkeetPipeline

  def init(opts) do
    {:producer, opts}
  end

  def process_skeets(skeets) when is_list(skeets) do
    SkeetPipeline
    |> Broadway.producer_names()
    |> List.first()
    |> GenStage.cast({:skeets, skeets})
  end

  def handle_demand(demand, state) do
    Logger.info("SkeetPipeline received demand for #{demand} skeets")
    events = []
    {:noreply, events, state}
  end

  def handle_cast({:skeets, skeets}, state) do
    {:noreply, skeets, state}
  end
end
