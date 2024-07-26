# Chatroom

启动方式：
```
PORT=4000 iex --sname node1 -S mix
PORT=4001 iex --sname node2 -S mix
...
PORT=n iex --sname noden -S mix
```
已支持无限扩容，只需在启动时指定不同的端口即可。

检查进程用这个：
```
DynamicSupervisor.which_children(Chatroom.ChatroomSupervisor)
```