defmodule EmoSkyWeb.Live.Index do
  use EmoSkyWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(EmoSky.PubSub, "skeets")
    end

    {:ok, socket |> stream(:skeets, [])}
  end

  def handle_info(skeet, socket) do
    {:noreply, stream_insert(socket, :skeets, skeet, limit: -10)}
  end
end
