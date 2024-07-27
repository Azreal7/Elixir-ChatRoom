defmodule ClientInfo do
  defstruct user_name: "user", room_name: "room_name"
end

defmodule Client do
  require Logger

  # room_name 存储client对应哪个room
  def init(user_and_room) do
    Logger.info("process #{inspect(self())} started")
    Room.connect(self(), user_and_room[:room_name])
    {:ok, user_and_room}
  end

  def handle_in({raw_message, _metadata}, user_and_room) when is_binary(raw_message) do
    # 解析JSON消息
    case Jason.decode(raw_message) do
      {:ok, %{"msg" => message}} ->
        Room.broadcast(self(), user_and_room[:room_name], message, user_and_room[:user_name])
        {:ok, user_and_room}
      _ ->
        # 处理解析失败或其他消息的情况
        {:ok, user_and_room}
    end
  end

  def terminate(:timeout, user_and_room) do
    Logger.info("client exited")
    Room.disconnect(self(), user_and_room[:room_name])
    {:ok, user_and_room}
  end

  def terminate(reason, user_and_room) do
    # 这里可以添加适当的日志记录或错误处理逻辑
    IO.puts("Client terminated with reason: #{inspect(reason)}")
    Room.disconnect(self(), user_and_room[:user_name])
    {:ok, user_and_room}
  end

  def handle_info({:message, message, :user_name, user_name, :time_stamp, time_stamp}, user_and_room) do
    data = %{
      message: message,
      user_name: user_name,
      time_stamp: time_stamp
    }
    payload = Jason.encode!(data)
    {:reply, :ok, {:text, payload}, user_and_room}
  end

  def handle_info(msg, user_and_room) do
    IO.inspect(msg, label: "Unhandled Info Message")
    {:ok, user_and_room}
  end
end
