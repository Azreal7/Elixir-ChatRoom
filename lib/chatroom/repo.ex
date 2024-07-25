defmodule Chatroom.Repo do
  use Ecto.Repo,
    otp_app: :chatroom,
    adapter: Mongo.Ecto
end
