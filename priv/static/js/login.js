document.getElementById('login-form').addEventListener('submit', async function(event) {
    event.preventDefault(); // 阻止表单默认提交行为

    const user_name = document.getElementById('username').value;
    const password = document.getElementById('password').value;

    try {
        // 发起登录请求（这里仅为示例，实际需替换为您的后端登录API地址）
        const response = await fetch('/api/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ user_name, password }),
        });

        if (response.ok) {
            const data = await response.json(); // 解析响应体为JSON
            sessionStorage.setItem("token", data.token);
            // 登录成功，跳转到/rooms

            window.location.href = '/rooms';
        } else {
            alert('登录失败，请检查您的用户名和密码。');
        }
    } catch (error) {
        console.error('登录请求出错:', error);
        alert('登录过程中发生错误，请稍后重试。');
    }
});
