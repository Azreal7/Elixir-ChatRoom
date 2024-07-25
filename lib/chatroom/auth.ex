defmodule Chatroom.Auth do
  def verify_password(name, password) do
    signer = Joken.Signer.create("HS256", "secret")
    true_password = Chatroom.User.get_password(name)
    # Logger.info("input password: #{inspect(password)}")
    # Logger.info("true password: #{inspect(true_password)}")
    if password == true_password do
      extra_claims = %{"user_name" => name, "password" => password}
      {:ok, Chatroom.Token.generate_and_sign!(extra_claims, signer)}
    else
      {:error, "failed to login"}
    end
  end

  def verify_token(token) do
    signer = Joken.Signer.create("HS256", "secret")
    Chatroom.Token.verify_and_validate(token, signer)
  end
end
