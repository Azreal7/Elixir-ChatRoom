defmodule ChatroomTest do
  use ExUnit.Case
  doctest Chatroom

  test "greets the world" do
    assert Chatroom.hello() == :world
  end
end
