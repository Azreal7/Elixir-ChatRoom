defmodule Chatroom.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
alias Chatroom.ChatroomSupervisor
  require Logger
  use Application

  @impl true
  def start(_type, _args) do
    port = System.get_env("PORT")
    topologies = Application.get_env(:libcluster, :topologies)
    Logger.info("args: #{inspect(port)}")
    webserver_spec = {Bandit, plug: Router, scheme: :http, port: port}
    children = [
      {Registry, keys: :unique, name: Registry.Room},
      {Cluster.Supervisor, [topologies, [name: Chatroom.ClusterSupervisor]]},
      {ChatroomSupervisor, port},
      Chatroom.Monitor,
      Chatroom.HashRing,
      Chatroom.Repo,
      webserver_spec
    ]

    opts = [strategy: :one_for_one, name: Chatroom.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
