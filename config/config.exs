import Config

config :chatroom, Chatroom.Repo,
  database: "chatroom_repo",
  hostname: "localhost"

config :libcluster,
  topologies: [
    example: [
      strategy: Cluster.Strategy.Gossip,
      config: [
        port: 45892
      ]
    ]
  ]
