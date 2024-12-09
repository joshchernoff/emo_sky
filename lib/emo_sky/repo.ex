defmodule EmoSky.Repo do
  use Ecto.Repo,
    otp_app: :emo_sky,
    adapter: Ecto.Adapters.SQLite3
end
