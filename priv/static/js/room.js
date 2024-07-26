const room_name = window.ROOM_NAME;
const socket = new WebSocket(`ws://localhost:4000/api/rooms/${room_name}/subscribe`);
const messageInput = document.getElementById('messageInput');
const responseArea = document.getElementById('responseArea');

console.log("room.js successfully loaded");

// 当WebSocket连接打开时
socket.addEventListener('open', (event) => {
    console.log('WebSocket connected.');
});

// 当从服务器接收到消息时
socket.addEventListener('message', (event) => {
    // const messageData = JSON.parse(event.data); 
    const message = event.data;
    // const processedMessage = processedMessage(messageData);
    // displayResponse(`Received from other user: ${processedMessage}`);
    displayResponse(`Received from other user: ${message}`)
});

// 发送消息到服务器
function sendMessage() {
    const message = messageInput.value.trim();
    if (message !== '') {
        socket.send(JSON.stringify({msg: message}));
        displayResponse(`You: ${message}`);
        messageInput.value = ''; // 清空输入框
    }
}

// 在页面上显示服务器响应
function displayResponse(text) {
    const p = document.createElement('p');
    p.textContent = text;
    responseArea.appendChild(p);
}

messageInput.addEventListener('keydown', (event) => {
    if (event.key == 'Enter') {
        event.preventDefault();
        sendMessage();
    }
})
