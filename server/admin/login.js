const API = 'http://localhost:3000';

const qs = (id) => document.getElementById(id);

async function api(path, body) {
  const res = await fetch(`${API}${path}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  if (!res.ok) throw new Error(await res.text());
  return res.json();
}

qs('login-btn').onclick = async () => {
  const email = qs('email').value;
  const password = qs('password').value;
  qs('login-error').innerText = '';
  try {
    const data = await api('/auth/login', { email, password });
    localStorage.setItem('token', data.token);
    localStorage.setItem('role', data.user.role);
    if (data.user.role === 'admin') {
      window.location.href = '/admin/admin.html';
    } else {
      window.location.href = '/admin/merchant.html';
    }
  } catch (e) {
    qs('login-error').innerText = 'Login failed';
  }
};
