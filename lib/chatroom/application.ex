defmodule Chatroom.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    webserver_spec = {Bandit, plug: Router, scheme: :http, port: 4000}
    children = [
      Chatroom.Repo,
      webserver_spec
    ]

    opts = [strategy: :one_for_one, name: Chatroom.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
