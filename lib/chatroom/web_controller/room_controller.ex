defmodule Chatroom.RoomController do
  require Logger

  def index(conn) do
    resp = EEx.eval_file("priv/static/rooms.html.eex", user_name: conn.params["user_name"])
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
        # 在supervisor中添加房间
        Chatroom.ChatroomSupervisor.new_room(name)

        conn
        |> Plug.Conn.put_status(:ok)
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, encoded_body)
      {:error, _} ->
        Plug.Conn.send_resp(conn, 401, "Unauthorized")
    end
  end

  def remove_room(conn) do
    {:ok, body_params, _conn} = Plug.Conn.read_body(conn)
    token = Plug.Conn.get_req_header(conn, "authorization")
    Logger.info("token: #{inspect(token)}")
    case Chatroom.Auth.verify_token(hd(token)) do
      {:ok, _} ->
        room_name = conn.params["room_name"]
        Logger.info(room_name)
        Chatroom.Rooms.remove_room(room_name)
        conn
        |> Plug.Conn.put_status(:ok)
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, "Successfully deleted")
      {:error, _} ->
        Plug.Conn.send_resp(conn, 401, "Unauthorized")
    end
  end
end
