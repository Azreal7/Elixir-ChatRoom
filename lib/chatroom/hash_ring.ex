defmodule Chatroom.HashRing do
  alias ElixirSense.Log
  use GenServer
  require Logger

  def handle_call({:add_node, node}, _from, ring) do
    Logger.info("adding #{inspect(node)}..")
    ExHashRing.Ring.add_node(ring, node)
    {:reply, :ok, ring}
  end

  def handle_call({:delete_node, node}, _from, ring) do
    Logger.info("removing #{inspect(node)}..")
    ExHashRing.Ring.remove_node(ring, node)
    {:reply, :ok, ring}
  end

  def handle_call({:find_node, room}, _from, ring) do
    {:ok, node} = ExHashRing.Ring.find_node(ring, room)
    {:reply, node, ring}
  end

  def handle_call({:get_nodes}, _from, ring) do
    Logger.info("nodes: #{inspect(ExHashRing.Ring.get_nodes(ring))}")
    {:reply, :ok, ring}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, ring} = ExHashRing.Ring.start_link()
    ExHashRing.Ring.add_node(ring, Node.self())
    Logger.info("HashRing GenServer pid: #{inspect(self())}, Ring pid: #{inspect(ring)}")
    {:ok, ring}
  end

  def add_node(node) do
    GenServer.call(__MODULE__, {:add_node, node})
  end

  def delete_node(node) do
    GenServer.call(__MODULE__, {:delete_node, node})
  end

  def find_node(room) do
    GenServer.call(__MODULE__, {:find_node, room})
  end

  def get_nodes do
    GenServer.call(__MODULE__, {:get_nodes})
  end
end
