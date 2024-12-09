defmodule EmoSky.BlueSky.AuthToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bluesky_auth_token" do
    field :access_token, :string
    field :refresh_token, :string
    field :did, :string
    field :email, :string
    field :email_auth_factor, :boolean
    field :email_confirmed, :boolean
    field :handle, :string

    timestamps()
  end

  @doc false
  def changeset(auth_token, attrs) do
    auth_token
    |> cast(attrs, [
      :access_token,
      :refresh_token,
      :did,
      :email,
      :email_auth_factor,
      :email_confirmed,
      :handle
    ])
    |> validate_required([
      :access_token,
      :refresh_token,
      :did,
      :email,
      :handle
    ])
  end
end
