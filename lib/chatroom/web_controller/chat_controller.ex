defmodule Chatroom.ChatController do
  require Logger
  def index(conn) do
    room_name = conn.params["room_name"]
    case Chatroom.Rooms.is_exist(room_name) do
      :ok -> Plug.Conn.send_resp(conn, 200, room_page(room_name))
      :error -> Plug.Conn.send_resp(conn, 404, "cannot find this room")
    end
  end

  defp room_page(room_name) do
    EEx.eval_file("priv/static/room.html.eex", room_name: room_name)
  end
end
