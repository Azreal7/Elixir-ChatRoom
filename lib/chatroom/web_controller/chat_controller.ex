defmodule Chatroom.ChatController do
  require Logger
  def index(conn) do
    room_name = conn.params["room_name"]
    user_name = conn.params["user_name"]
    Logger.info("user_name: #{user_name}")
    case Chatroom.Rooms.is_exist(room_name) do
      :ok -> Plug.Conn.send_resp(conn, 200, room_page(room_name, user_name))
      :error -> Plug.Conn.send_resp(conn, 404, "cannot find this room")
    end
  end

  defp room_page(room_name, user_name) do
    EEx.eval_file("priv/static/room.html.eex", room_name: room_name, user_name: user_name)
  end

  def update(conn) do
    Logger.info("trying to update..")
    conn
    |> WebSockAdapter.upgrade(Client, %{room_name: conn.params["room_name"], user_name: conn.params["user_name"]}, timeout: :infinity)
    |> Plug.Conn.halt()
  end
end
