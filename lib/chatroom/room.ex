defmodule RoomInfo do
  defstruct name: "room", sessions: [], history_message: []
end

defmodule Room do
  use GenServer
  require Logger

  def start_link(room_name) do
    # Logger.info("room: #{inspect(room_name)}")
    GenServer.start_link(__MODULE__, room_name, name: {:global, :"#{room_name}"})
  end

  def init(name) do
    {:ok, %RoomInfo{name: name, sessions: [], history_message: Chatroom.Message.get_messages(name)}}
  end

  def handle_call({:add_session, session}, _from, room_info) do
    Logger.info("#{inspect(session)} is trying to connect")
    # 发送前100条消息
    Enum.each(room_info.history_message, fn message ->
      send(session, {:message, message})
    end)
    {:reply, :ok, %RoomInfo{room_info | sessions: room_info.sessions ++ [session]}}
  end

  def handle_call({:mongo, message}, _from, room_info) do
    Logger.info("trying to add message to mongo..")
    history_message = if length(room_info.history_message) >= 100 do
      tl(room_info.history_message)
    else
      room_info.history_message
    end
    history_message = history_message ++ [message]
    Chatroom.Message.add_message(message, "sender", room_info.name, DateTime.to_string(DateTime.utc_now()))
    {:reply, :ok, %RoomInfo{room_info | history_message: history_message}}
  end

  def handle_cast({:remove_session, session}, room_info) do
    new_sessions = room_info.sessions -- [session]
    if new_sessions == [] do
      Logger.info("Shutting down room #{room_info.name} as the last session is removed.")
      {:stop, :normal, %RoomInfo{room_info | sessions: new_sessions}}
    else
      {:noreply, %RoomInfo{room_info | sessions: new_sessions}}
    end
  end

  def handle_cast({:broadcast, message, sender}, room_info) do
    Enum.each(room_info.sessions, fn session ->
      if session != sender do
        session |> send({:message, message})
      end
    end)
    {:noreply, room_info}
  end

  ### Client API

  def connect(pid, room_name) do
    case :global.whereis_name(:"#{room_name}") do
      :undefined -> Chatroom.ChatroomSupervisor.new_room(room_name)
      _ -> nil
    end
    GenServer.call({:global, :"#{room_name}"}, {:add_session, pid})
  end

  def broadcast(pid, room_name, message) do
    Logger.info("trying to broadcast")
    GenServer.cast({:global, :"#{room_name}"}, {:broadcast, message, pid})
    GenServer.call({:global, :"#{room_name}"}, {:mongo, message})
  end

  def disconnect(pid, room_name) do
    Logger.info("#{inspect(pid)} is trying to disconnect")
    GenServer.cast({:global, :"#{room_name}"}, {:remove_session, pid})
  end
end
