defmodule EmoSky.Repo.Migrations.AddBlueskyAuth do
  use Ecto.Migration

  def change do
    create table(:bluesky_auth_token) do
      add :access_token, :text, null: false
      add :refresh_token, :text, null: false
      add :did, :string, null: false
      add :email, :string, null: false
      add :email_auth_factor, :boolean, default: false
      add :email_confirmed, :boolean, default: false
      add :handle, :string, null: false

      timestamps()
    end
  end
end
