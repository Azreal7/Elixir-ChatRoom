defmodule Unauthorized do
  defexception message: "Unauthorized", plug_status: 401
end

defmodule Chatroom.User do
  use Ecto.Schema
  import Ecto.Query
  require Logger

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "user" do
    field :user_name, :string
    field :password, :string
  end

  def add_user(name, password) do
    user = %Chatroom.User{user_name: name, password: password}
    Chatroom.Repo.insert!(user)
  end

  def all_users do
    (from u in Chatroom.User,
      select: u.user_name)
    |> Chatroom.Repo.all()
  end

  def get_password(user_name) do
    (from u in Chatroom.User,
      where: u.user_name == ^user_name,
      select: u.password)
    |> Chatroom.Repo.one()
  end
end
