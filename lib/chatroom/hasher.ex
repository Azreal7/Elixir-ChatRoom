defmodule Chatroom.Hasher do
  @moduledoc """
  Module for hashing a string and mapping it to 1 to n.
  """

  @spec map_string_to_range(String.t(), integer()) :: integer()
  def map_string_to_range(string, n) when is_binary(string) and n > 0 do
    hash = :crypto.hash(:md5, string) |> :binary.decode_unsigned()
    map_hash_to_range(hash, n)
  end

  def map_hash_to_range(hash, n) do
    rem(hash, n) + 1
  end
end
