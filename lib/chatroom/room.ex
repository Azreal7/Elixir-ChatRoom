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

  def init(room_name) do
    Logger.info("room #{inspect(room_name)} init..")
    {:ok, %RoomInfo{name: room_name, sessions: [], history_message: Chatroom.Message.get_messages(room_name)}}
  end

  def handle_call({:add_session, session}, _from, room_info) do
    Logger.info("#{inspect(session)} is trying to connect")
    # 发送前100条消息
    Enum.each(room_info.history_message, fn message ->
      send(session, {:message, message[:content], :user_name, message[:sender], :time_stamp, message[:time_stamp]})
    end)
    {:reply, :ok, %RoomInfo{room_info | sessions: room_info.sessions ++ [session]}}
  end

  def handle_call({:mongo, message, user_name}, _from, room_info) do
    Logger.info("trying to add message to mongo..")
    history_message = if length(room_info.history_message) >= 100 do
      tl(room_info.history_message)
    else
      room_info.history_message
    end
    time_stamp = DateTime.utc_now()|> Calendar.strftime("%Y-%m-%d %H:%M:%S")
    history_message = history_message ++ [%{content: message, sender: user_name, time_stamp: time_stamp}]
    Chatroom.Message.add_message(message, user_name, room_info.name, time_stamp)
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

  def handle_cast({:broadcast, message, _sender, user_name}, room_info) do
    time_stamp = DateTime.utc_now()|> Calendar.strftime("%Y-%m-%d %H:%M:%S")
    Enum.each(room_info.sessions, fn session ->
      session |> send({:message, message, :user_name, user_name, :time_stamp, time_stamp})
    end)
    {:noreply, room_info}
  end

  ### Client API

  def connect(pid, room_name) do
    case :global.whereis_name(:"#{room_name}") do
      :undefined -> Chatroom.ChatroomSupervisor.new_room(room_name)
      _ -> nil
    end
    :timer.sleep(500)
    GenServer.call({:global, :"#{room_name}"}, {:add_session, pid})
  end

  def broadcast(pid, room_name, message, user_name) do
    Logger.info("trying to broadcast")
    GenServer.cast({:global, :"#{room_name}"}, {:broadcast, message, pid, user_name})
    GenServer.call({:global, :"#{room_name}"}, {:mongo, message, user_name})
  end

  def disconnect(pid, room_name) do
    Logger.info("#{inspect(pid)} is trying to disconnect")
    GenServer.cast({:global, :"#{room_name}"}, {:remove_session, pid})
  end
end
