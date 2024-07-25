defmodule Chatroom.Rooms do
  use Ecto.Schema
  import Ecto.Query
  require Logger

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "rooms" do
    field :room_name, :string
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
    (from r in Chatroom.Rooms, where: r.room_name == room_name, select: r)
    |> Chatroom.Repo.one()
  end
end
