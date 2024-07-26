defmodule Router do
  use Plug.Router
  require Logger
  plug Plug.Static,
    at: "/",
    from: :chatroom,
    only: ~w(css js)
  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/", do: Chatroom.LoginController.index(conn)
  get "/login", do: Chatroom.LoginController.index(conn)
  post "/api/login", do: Chatroom.LoginController.login(conn)
  get "/rooms", do: Chatroom.RoomController.index(conn)
  get "/api/rooms", do: Chatroom.RoomController.refresh_list(conn, nil)
  post "/api/rooms", do: Chatroom.RoomController.create_room(conn)
  get "/rooms/:room_name", do: Chatroom.ChatController.index(conn)
  post "/api/users", do: Chatroom.LoginController.register(conn)
  get "api/rooms/:room_name/subscribe", do: Chatroom.ChatController.update(conn)
  match _, do: send_resp(conn, 404, "not found")
end
