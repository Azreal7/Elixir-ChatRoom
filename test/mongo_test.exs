defmodule MongoTest do
  use ExUnit.Case

  test "get_password" do
    password = Chatroom.User.get_password("admin")
    assert password == "admin"
  end

  test "generate_and_check_token" do
    {:ok, token} = Chatroom.Auth.verify_password("admin", "admin")
    {:ok, claims} = Chatroom.Auth.verify_token(token)
    assert claims["user_name"] == "admin"
  end

  test "add_and_remove_room" do
    room_name = "mongo_test_room"
    Chatroom.Rooms.add_room(room_name)
    assert :ok == Chatroom.Rooms.is_exist(room_name)
    assert {:ok, "Room successfully deleted"} == Chatroom.Rooms.remove_room(room_name)
  end
end
