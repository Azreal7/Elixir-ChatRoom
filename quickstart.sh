#!/bin/bash

# 启动节点的起始端口号
START_PORT=4000
END_PORT=4002

# 节点名称前缀
NODE_NAME_PREFIX="node"

# 要进入的工作目录
WORK_DIR="Documents/homework/chatroom"

# 遍历端口范围并在每个端口启动一个独立的 iex 节点
for ((i=0; i<=$(($END_PORT - $START_PORT)); i++)); do
  PORT=$(($START_PORT + $i))
  NODE_NAME="${NODE_NAME_PREFIX}${i}@localhost"

  osascript <<EOF
tell application "iTerm"
  create window with default profile
  tell current session of current window
    write text "cd ${WORK_DIR} && PORT=${PORT} iex --sname ${NODE_NAME} -S mix"
  end tell
end tell
EOF

done