defmodule MongoTest do
  use ExUnit.Case
  doctest Chatroom

  test "get_password" do
    password = Chatroom.User.get_password("admin")
    assert password == "admin"
  end

  test "generate_and_check_token" do
    {:ok, token} = Chatroom.Auth.verify_password("admin", "admin")
    {:ok, claims} = Chatroom.Auth.verify_token(token)
    assert claims["user_name"] == "admin"
  end
end
