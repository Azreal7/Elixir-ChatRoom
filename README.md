# Chatroom

启动方式：
```
PORT=4000 iex --sname node1 -S mix
PORT=4001 iex --sname node2 -S mix
Node.connect(:"node1@localhost")
```

检查进程用这个：
```
DynamicSupervisor.which_children(Chatroom.ChatroomSupervisor)
```