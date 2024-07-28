ExUnit.start()
System.put_env("PORT", "4001")

{:ok, _} = Application.ensure_all_started(:chatroom)
