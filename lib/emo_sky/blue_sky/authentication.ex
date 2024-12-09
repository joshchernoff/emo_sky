defmodule EmoSky.Client.BlueSky.Authentication do
  @moduledoc """
  Module for handling Bluesky authentication.
  """

  use GenServer

  @url "https://bsky.social/xrpc/com.atproto.server.createSession"

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def init(:ok) do
    {:ok, %{}}
  end

  # Public function to authenticate and get a token
  def authenticate(username, password) do
    case get_token(username) do
      {:ok, access_token} ->
        {:ok, access_token}

      _ ->
        authenticate_and_store_token(username, password)
    end
  end

  defp get_token(username) do
    case EmoSky.BlueSky.get_auth_token(username) do
      %{access_token: access_token} ->
        {:ok, %{access_token: access_token}}

      _ ->
        {:error, "Token not found"}
    end
  end

  defp authenticate_and_store_token(username, password) do
    body = %{
      "identifier" => username,
      "password" => password
    }

    case Req.post(@url, json: body) |> dbg() do
      {:ok, %{status: 200, body: response}} ->
        response
        |> map_auth_response()
        |> EmoSky.BlueSky.create_auth_token()
        |> dbg()

      {:ok, %{status: status, body: response}} ->
        {:error, "Request failed with status #{status}: #{inspect(response)}"}

      {:error, reason} ->
        {:error, "Request failed: #{inspect(reason)}"}
    end
  end

  defp map_auth_response(%{
         "accessJwt" => access_token,
         "refreshJwt" => refresh_token,
         "did" => did,
         "didDoc" => did_doc,
         "email" => email,
         "emailAuthFactor" => email_auth_factor,
         "emailConfirmed" => email_confirmed,
         "handle" => handle
       }) do
    %{
      access_token: access_token,
      refresh_token: refresh_token,
      did: did,
      did_doc: did_doc,
      email: email,
      email_auth_factor: email_auth_factor,
      email_confirmed: email_confirmed,
      handle: handle
    }
  end
end
