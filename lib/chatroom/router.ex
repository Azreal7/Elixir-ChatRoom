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

  # 根目录与登录界面
  get "/", do: Chatroom.LoginController.index(conn)
  get "/login_page", do: Chatroom.LoginController.index(conn)

  # 用户操作相关
  post "/api/login", do: Chatroom.LoginController.login(conn)
  get "/users/:user_name/rooms", do: Chatroom.RoomController.index(conn)
  get "/users/:user_name/rooms/:room_name", do: Chatroom.ChatController.index(conn)
  post "/users", do: Chatroom.LoginController.register(conn)

  # 聊天相关
  get "/users/:user_name/rooms/:room_name/subscribe", do: Chatroom.ChatController.update(conn)

  # 房间相关
  get "/rooms", do: Chatroom.RoomController.refresh_list(conn, nil)
  post "/rooms", do: Chatroom.RoomController.create_room(conn)
  delete "/rooms/:room_name", do: Chatroom.RoomController.remove_room(conn)

  # 处理未匹配路由
  match _, do: send_resp(conn, 404, "not found")
end
