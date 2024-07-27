defmodule Chatroom.Message do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  require Logger

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "message" do
    field :content, :string
    field :sender, :string
    field :chatroom_name, :string
    field :time_stamp, :string
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :sender, :chatroom_name, :time_stamp])
    |> validate_required([:content, :sender, :chatroom_name, :time_stamp])
    |> validate_length(:content, min: 1, max: 1000)
  end

  def get_messages(chatroom_name) do
    (from m in Chatroom.Message,
      where: m.chatroom_name == ^chatroom_name,
      # limit: 2,
      select: %{content: m.content, sender: m.sender, time_stamp: m.time_stamp})
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

  def clean_message(room_name) do
    Logger.info("cleaning #{room_name} message..")
    q = from(m in Chatroom.Message,
      where: m.chatroom_name == ^room_name)
    Logger.info("query: #{inspect(q)}")
    {count, _} = Chatroom.Repo.delete_all(q)
    Logger.info("Deleted #{count} messages")
    {:ok, "Deleted #{count} messages"}
  end
end
