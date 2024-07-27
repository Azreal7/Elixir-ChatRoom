# Chatroom

启动方式：
```
sh quickstart.sh
```
修改WORK_DIR为你的项目路径即可。
需要动态增删节点调整nginx配置和quickstart.sh脚本。

检查进程用这个：
```
DynamicSupervisor.which_children(Chatroom.ChatroomSupervisor)
```