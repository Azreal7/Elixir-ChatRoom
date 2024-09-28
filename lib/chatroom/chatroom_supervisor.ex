defmodule Chatroom.ChatroomSupervisor do
  use DynamicSupervisor
  require Logger

  def init(port) do
    Logger.info("port: #{inspect(port)}")
    # 启动时自动和其他节点连接
    :pg.start_link
    :pg.join(:chat, self())
    auto_connect(:chat)
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def auto_connect(group) do
    members = :pg.get_members(group)
    nodes = Enum.map(members, &node(&1))
    Enum.each(nodes, &Node.connect/1)
  end

  def new_room(room_name) do
    target_node = Chatroom.HashRing.find_node(room_name)
    Logger.info("In supervisor, trying to start #{room_name} in #{inspect(target_node)}")
    spec = %{
      id: {:room, room_name},
      start: {Room, :start_link, [room_name]},
      restart: :transient,
      type: :worker
    }
    :rpc.call(
      target_node,
      DynamicSupervisor,
      :start_child,
      [Chatroom.ChatroomSupervisor, spec]
    )
  end

  def start_link(port) do
    # Logger.info("hello WorkerSupervisor!")
    DynamicSupervisor.start_link(__MODULE__, port, name: __MODULE__)
  end
end
