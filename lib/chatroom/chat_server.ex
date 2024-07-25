defmodule ChatServer do
  use GenServer
  require Logger

  def start_link(room_name) do
    # Logger.info("room: #{inspect(room_name)}")
    GenServer.start_link(__MODULE__, room_name, name: {:global, :"#{room_name}"})
  end

  def init(name) do
    {:ok, %{name: name, sessions: %{}}}
  end

  def handle_cast({:add_session, session}, state) do
    Logger.info("#{inspect(session)} is trying to connect")
    # 发送前100条消息
    history_message = Chatroom.Message.get_messages(state.name)
    Enum.each(history_message, fn message ->
      send(session, {:message, message})
    end)
    {:noreply, %{name: state.name, sessions: Map.put(state.sessions, session, [])}}
  end

  def handle_cast({:remove_session, session}, state) do
    {:noreply, %{name: state.name, sessions: Map.delete(state.sessions, session)}}
  end

  def handle_cast({:broadcast, message, sender}, state) do
    Enum.each(state.sessions, fn {session, _} ->
      if session != sender do
        session |> send({:message, message})
        # EchoServer.get_message(session, message)
      end
    end)
    {:noreply, state}
  end

  def handle_cast({:mongo, message}, state) do
    Logger.info("trying to add message to mongo..")
    Chatroom.Message.add_message(message, "sender", state.name, DateTime.to_string(DateTime.utc_now()))
    {:noreply, state}
  end

  ### Client API

  def connect(pid, room_name) do
    GenServer.cast({:global, :"#{room_name}"}, {:add_session, pid})
  end

  def broadcast(pid, room_name, message) do
    Logger.info("trying to broadcast")
    GenServer.cast({:global, :"#{room_name}"},
    {:broadcast, message, pid})
    GenServer.cast({:global, :"#{room_name}"}, {:mongo, message})
  end

  def disconnect(pid, room_name) do
    Logger.info("#{inspect(pid)} is trying to disconnect")
    GenServer.cast({:global, :"#{room_name}"}, {:remove_session, pid})
  end
end
