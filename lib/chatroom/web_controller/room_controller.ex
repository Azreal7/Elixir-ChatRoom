defmodule Chatroom.RoomController do
  require Logger

  def index(conn) do
    resp = case File.read("priv/static/rooms.html") do
      {:ok, body} -> body
      {:error, _reason} -> "failed to load rooms website"
    end
    Plug.Conn.send_resp(conn, 200, resp)
  end

  @spec refresh_list(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def refresh_list(conn, __params) do
    token = Plug.Conn.get_req_header(conn, "authorization")
    Logger.info("token: #{inspect(token)}")
    case Chatroom.Auth.verify_token(hd(token)) do
      {:ok, _} ->
        rooms_list = %{rooms: Chatroom.Rooms.get_list}
        encoded_body = Jason.encode!(rooms_list)
        conn
        |> Plug.Conn.put_status(:ok)
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, encoded_body)
      {:error, _} ->
        Plug.Conn.send_resp(conn, 401, "Unauthorized")
      end
  end

  def create_room(conn) do
    {:ok, body_params, _conn} = Plug.Conn.read_body(conn)
    token = Plug.Conn.get_req_header(conn, "authorization")
    Logger.info("token: #{inspect(token)}")
    case Chatroom.Auth.verify_token(hd(token)) do
      {:ok, _} ->
        json_data = %{status: :ok, message: "Create room successful", token: token}
        encoded_body = Jason.encode!(json_data)
        %{"name" => name} = Jason.decode!(body_params)
        Chatroom.Rooms.add_room(name)
        conn
        |> Plug.Conn.put_status(:ok)
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, encoded_body)
      {:error, _} ->
        Plug.Conn.send_resp(conn, 401, "Unauthorized")
      end
  end
end
