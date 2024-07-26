defmodule Chatroom.Monitor do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    # 开始监控节点连接
    :net_kernel.monitor_nodes(true, [])
    {:ok, %{}}
  end

  def handle_info({:nodeup, node}, state) do
    IO.puts("Node connected: #{inspect(node)}")
    # 将新节点添加到 HashRing
    Chatroom.HashRing.add_node(node)
    {:noreply, state}
  end

  def handle_info({:nodedown, node}, state) do
    IO.puts("Node disconnected: #{inspect(node)}")
    # 将断开的节点从 HashRing 中移除
    Chatroom.HashRing.delete_node(node)
    {:noreply, state}
  end
end
