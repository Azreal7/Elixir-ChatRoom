defmodule Chatroom.Rooms do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  require Logger

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "rooms" do
    field :room_name, :string
  end

  def changeset(room, attrs) do
    room
    |> cast(attrs, [:room_name])
    |> validate_required([:room_name])
  end

  def get_list do
    (from r in Chatroom.Rooms, select: r)
    |> Chatroom.Repo.all()
    |> Enum.map(fn(room) -> room.room_name end)
  end

  def add_room(room_name) do
    %Chatroom.Rooms{room_name: room_name}
    |> Chatroom.Repo.insert!()
  end

  def is_exist(room_name) do
    res = (from r in Chatroom.Rooms, where: r.room_name == ^room_name, select: r)
    |> Chatroom.Repo.one()
    case res do
      nil -> :error
      _ -> :ok
    end
  end

  def remove_room(room_name) do
    case Chatroom.Repo.get_by(Chatroom.Rooms, room_name: room_name) do
      nil -> {:error, "Room not found"}
      room ->
        Logger.info("room: #{inspect(room)}")
        case Chatroom.Repo.delete(room) do
          {:ok, _} ->
            # Logger.info("deleted room from room list")
            Chatroom.Message.clean_message(room_name)
            Logger.info("Room successfully deleted")
            {:ok, "Room successfully deleted"}
          {:error, reason} ->
            {:error, reason}
        end
    end
  end
end
