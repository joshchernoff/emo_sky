defmodule EmoSky.BlueSky do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query
  alias EmoSky.Repo
  alias EmoSky.BlueSky.AuthToken

  def get_auth_token(username) do
    from(a in AuthToken, where: a.handle == ^username)
    |> Repo.one()
  end

  def create_auth_token(attr) do
    %AuthToken{}
    |> AuthToken.changeset(attr)
    |> Repo.insert()
  end
end
