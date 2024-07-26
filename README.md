# Chatroom

启动方式：
```
PORT=4000 iex --sname node1 -S mix
PORT=4001 iex --sname node2 -S mix
...
PORT=400n iex --sname noden -S mix
```
现已支持动态扩容，结合nginx反向代理，可以一个域名对应多个节点，实现负载均衡。

检查进程用这个：
```
DynamicSupervisor.which_children(Chatroom.ChatroomSupervisor)
```