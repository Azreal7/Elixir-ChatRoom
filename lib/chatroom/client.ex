defmodule Client do
  require Logger

  # room_name 存储client对应哪个room
  def init(room_name) do
    Logger.info("process #{inspect(self())} started")
    Room.connect(self(), room_name)
    {:ok, room_name}
  end

  def handle_in({raw_message, _metadata}, room_name) when is_binary(raw_message) do
    # 解析JSON消息
    case Jason.decode(raw_message) do
      {:ok, %{"msg" => message}} ->
        Room.broadcast(self(), room_name, message)
        {:ok, room_name}
      _ ->
        # 处理解析失败或其他消息的情况
        {:ok, room_name}
    end
  end

  def terminate(:timeout, room_name) do
    Room.disconnect(self(), room_name)
    {:ok, room_name}
  end

  def terminate(reason, room_name) do
    # 这里可以添加适当的日志记录或错误处理逻辑
    IO.puts("Client terminated with reason: #{inspect(reason)}")
    {:ok, room_name}
  end

  def handle_info({:message, message}, room_name) do
    # IO.inspect("Received a message: #{inspect(message)}")
    # json_message = Jason.encode!(message)
    # {:reply, :ok, {:text, json_message}, room_name}
    {:reply, :ok, {:text, message}, room_name}
  end

  def handle_info(msg, room_name) do
    IO.inspect(msg, label: "Unhandled Info Message")
    {:ok, room_name}
  end
end
