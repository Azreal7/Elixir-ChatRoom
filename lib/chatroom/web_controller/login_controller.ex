defmodule Chatroom.LoginController do

  require Logger

  def index do
    login_page()
  end

  defp login_page do
    case File.read("priv/static/login.html") do
      {:ok, body} -> body
      {:error, _reason} -> "failed to load login website"
    end
  end

  def login(conn) do
    {:ok, body_params, _conn} = Plug.Conn.read_body(conn)

    Logger.info("#{inspect(body_params)}")

    %{"password" => password, "user_name" => name} = Jason.decode!(body_params)

    case Chatroom.Auth.verify_password(name, password) do
      {:ok, token} ->
        json_data = %{status: :ok, message: "Login successful", token: token}
        encoded_body = Jason.encode!(json_data)
        # 处理登录成功逻辑
        conn
        |> Plug.Conn.put_status(:ok)
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(200, encoded_body)
      {:error, reason} ->
        error_data = %{status: :error, error: reason}
        encoded_error_body = Jason.encode!(error_data)
        conn
        |> Plug.Conn.put_status(401)
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.send_resp(401, encoded_error_body)
    end
  end

  def register(conn) do
    {:ok, body_params, _conn} = Plug.Conn.read_body(conn)
    %{"password" => password, "user_name" => name} = Jason.decode!(body_params)
    Chatroom.User.add_user(name, password)
    Plug.Conn.send_resp(conn, 200, "successfully registered")
  end
end
