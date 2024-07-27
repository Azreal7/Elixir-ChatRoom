const room_name = window.ROOM_NAME;
const user_name = window.USER_NAME;
const socket = new WebSocket(`ws://localhost:4000/api/users/${user_name}/rooms/${room_name}/subscribe`);
const messageInput = document.getElementById('messageInput');
const responseArea = document.getElementById('responseArea');

console.log("room.js successfully loaded");

// 当WebSocket连接打开时
socket.addEventListener('open', (event) => {
    console.log('WebSocket connected.');
});

// 当从服务器接收到消息时
socket.addEventListener('message', (event) => {
    const messageData = JSON.parse(event.data);
    const userName = messageData.user_name;
    const message = messageData.message;
    const time_stamp = messageData.time_stamp;
    displayResponse(`${userName}: ${message}`, time_stamp);
});

// 发送消息到服务器
function sendMessage() {
    const message = messageInput.value.trim();
    if (message !== '') {
        const time_stamp = new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' }); // 格式化客户端时间
        socket.send(JSON.stringify({ msg: message, time_stamp: time_stamp }));
        messageInput.value = ''; // 清空输入框
    }
}

// 在页面上显示服务器响应
function displayResponse(text, timestamp) {
    const p = document.createElement('p');
    const messageSpan = document.createElement('span');
    messageSpan.textContent = text;

    const timestampSpan = document.createElement('span');
    timestampSpan.className = 'timestamp';
    timestampSpan.textContent = timestamp;

    p.appendChild(messageSpan);
    p.appendChild(timestampSpan);
    responseArea.appendChild(p);
}

messageInput.addEventListener('keydown', (event) => {
    if (event.key === 'Enter') {
        event.preventDefault();
        sendMessage();
    }
});
