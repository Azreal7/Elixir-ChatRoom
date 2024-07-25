defmodule Router do
  use Plug.Router
  plug Plug.Static,
    at: "/",
    from: :chatroom,
    only: ~w(css js)


  require Logger
  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "")
  end

  get "/login" do
    resp = Chatroom.LoginController.index
    send_resp(conn, 200, resp)
  end

  post "/api/login", do: Chatroom.LoginController.login(conn)

  get "/rooms" do
    Chatroom.RoomController.index(conn)
  end

  get "api/rooms", do: Chatroom.RoomController.refresh_list(conn, nil)

  post "api/rooms", do: Chatroom.RoomController.create_room(conn)

  # post "api/rooms", do: Chatroom.RoomController.refresh_list(conn, nil)

  # get "/websocket" do
  #   conn
  #   |> WebSockAdapter.upgrade(EchoServer, [], timeout: :infinity)
  #   |> halt()
  # end

  match _ do
    # Logger.info("wtf")
    send_resp(conn, 404, "not found")
  end
end
