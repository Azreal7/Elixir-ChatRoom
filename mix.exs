defmodule Chatroom.MixProject do
  use Mix.Project

  def project do
    [
      app: :chatroom,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :mongodb_ecto, :ecto],
      mod: {Chatroom.Application, []}
    ]

  end

  # Run "mix help deps" to learn about dependencies.
  def deps do
    [
      {:mongodb_ecto, "~> 1.0.0"},
      {:joken, "~> 2.6"},
      {:jason, "~> 1.4"},
      {:plug, "~> 1.12"},
      {:bandit, "~> 1.5.5"},
      {:libcluster, "~> 3.0"},
      {:websock_adapter, "~> 0.5.6"},
      {:ex_hash_ring, "~> 6.0"},
      {:postgrex, "~> 0.15.7", only: [:prod]}
    ]
  end
end
