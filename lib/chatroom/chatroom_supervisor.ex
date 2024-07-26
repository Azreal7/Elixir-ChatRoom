defmodule Chatroom.ChatroomSupervisor do
  use DynamicSupervisor
  require Logger

  def init(port) do
    Logger.info("port: #{inspect(port)}")
    res = DynamicSupervisor.init(strategy: :one_for_one)
    Task.start(fn ->
      :timer.sleep(500)
      init_room(port)
    end)
    res
  end

  def init_room(port) do
    room_list = Chatroom.Rooms.get_list()
    Enum.each(room_list, fn room ->
      if Chatroom.Hasher.map_string_to_range(room, 2) == Chatroom.Hasher.map_hash_to_range(String.to_integer(port), 2) do
        new_room(room)
      end
    end)
  end

  def new_room(room_name) do
    # Logger.info("In supervisor, trying to start #{room_name}")
    spec = %{
      id: {:room, room_name},
      start: {Room, :start_link, [room_name]},
      restart: :permanent,
      type: :worker
    }
    DynamicSupervisor.start_child(Chatroom.ChatroomSupervisor, spec)
  end

  def start_link(port) do
    # Logger.info("hello WorkerSupervisor!")
    DynamicSupervisor.start_link(__MODULE__, port, name: __MODULE__)
  end
end
