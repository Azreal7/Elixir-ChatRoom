defmodule Chatroom.Message do
  use Ecto.Schema
  import Ecto.Query
  require Logger

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "message" do
    field :content, :string
    field :sender, :string
    field :chatroom_name, :string
    field :time_stamp, :string
  end

  def get_messages(chatroom_name) do
    (from m in Chatroom.Message,
      where: m.chatroom_name == ^chatroom_name,
      order_by: [desc: :time_stamp],
      # limit: 2,
      select: {m.sender, m.content})
    |> Chatroom.Repo.all()
  end

  def all_messages do
    (from m in Chatroom.Message,
      select: m.content)
    |> Chatroom.Repo.all()
  end

  def add_message(content, sender, chatroom, time) do
    message = %Chatroom.Message{content: content, sender: sender, chatroom_name: chatroom, time_stamp: time}
    Chatroom.Repo.insert!(message)
  end
end
