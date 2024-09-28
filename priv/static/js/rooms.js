document.addEventListener('DOMContentLoaded', function() {
    const user_name = window.USER_NAME;
    console.log(user_name);
    const roomListElement = document.getElementById('room-list');
    const createRoomBtn = document.getElementById('create-room-btn');
    const roomNameInput = document.getElementById('room-name-input');

    // 获取聊天室列表
    async function fetchRoomList() {
        try {
            console.log("Attempting to read token...");
            const token = sessionStorage.getItem('token');
            console.log(token);
            const response = await fetch('/rooms', {
                headers: {
                    'Authorization' : `${token}`
                }
            });
            console.log("fetch success...");
            if (!response.ok) {
                throw new Error('Failed to fetch rooms');
            }
            const data = await response.json();
            renderRoomList(data.rooms);
        } catch (error) {
            console.error('Error fetching rooms:', error);
            window.location.href = '/login';
        }
    }

    // 渲染聊天室列表
    function renderRoomList(rooms) {
        roomListElement.innerHTML = '';
        rooms.forEach(room => {
            const li = document.createElement('li');
            li.textContent = room;
            li.classList.add('room-item');
            console.log(room);

            // 创建删除按钮
            const deleteBtn = document.createElement('button');
            deleteBtn.textContent = '删除';
            deleteBtn.classList.add('delete-btn');
            deleteBtn.onclick = async (event) => {
                event.stopPropagation(); // 防止触发li的点击事件
                try {
                    const token = sessionStorage.getItem('token');
                    const response = await fetch(`/rooms/${room}`, {
                        method: 'DELETE',
                        headers: {
                            'Authorization': `${token}`
                        }
                    });
                    if (response.ok) {
                        await fetchRoomList();
                    } else {
                        throw new Error('Failed to delete room');
                    }
                } catch (error) {
                    console.error('Error deleting room:', error);
                    alert('Failed to delete room. Please try again or login');
                }
            };

            li.appendChild(deleteBtn);
            li.onclick = () => window.location.href = `/users/${user_name}/rooms/${room}`;
            roomListElement.appendChild(li);
        });
    }

    // 创建聊天室
    createRoomBtn.onclick = async () => {
        const roomName = roomNameInput.value.trim();
        const token = sessionStorage.getItem('token');
        if (!roomName) return alert('Room name cannot be empty.');
        try {
            // 发送创建房间请求
            const response = await fetch('/rooms', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization' : `${token}`
                },
                body: JSON.stringify({ name: roomName }),
            });
            if (response.ok) {
                // 成功创建，刷新房间列表
                await fetchRoomList();
                roomNameInput.value = ''; // 清空输入框
            } else {
                throw new Error('Failed to create room');
            }
        } catch (error) {
            console.error('Error creating room:', error);
            alert('Failed to create room. Please try again or login');
        }
    };

    // 页面加载时获取房间列表
    fetchRoomList();
});
