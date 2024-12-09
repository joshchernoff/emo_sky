defmodule EmoSky.Client.BlueSky.JetStream do
  use WebSockex
  require Logger

  alias EmoSky.Client.BlueSky.Authentication

  def start_link(_) do
    url = "wss://jetstream1.us-west.bsky.network/subscribe?wantedCollections[]=app.bsky.feed.post"
    user = EmoSky.config([:blue_sky, :user])
    pass = EmoSky.config([:blue_sky, :pass])
    # Attempt authentication before starting the WebSocket connection
    case Authentication.authenticate(user, pass) |> dbg() do
      {:ok, %{access_token: access_token}} ->
        # If authentication is successful, proceed to start the WebSocket
        WebSockex.start_link(url, __MODULE__, %{access_token: access_token})

      {:error, reason} ->
        Logger.error("Authentication failed: #{inspect(reason)}")
        {:stop, reason}
    end
  end

  def init(state) do
    Logger.info("Successfully authenticated and connected.")
    {:ok, state}
  end

  @impl true
  def handle_connect(_conn, state) do
    Logger.info("Successfully connected to Bluesky Firehose.")
    {:ok, state}
  end

  @impl true
  def handle_frame({_type, msg}, state) do
    case Jason.decode(msg) do
      {:ok, parsed_msg} ->
        parsed_msg
        |> filter_for_posts()
        |> do_something()

      {:error, reason} ->
        Logger.error("Failed to decode JSON: #{inspect(reason)}")
    end

    {:ok, state}
  end

  def filter_for_posts(
        %{"commit" => %{"collection" => "app.bsky.feed.post", "operation" => "create"}} = msg
      ),
      do: msg

  def filter_for_posts(_), do: nil

  def do_something(nil), do: nil

  def do_something(msg) do
    # Send to analyis checker
    EmoSky.BlueSky.SkeetProducer.process_skeets([msg])
  end
end
