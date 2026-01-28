const API = 'http://localhost:3000';
let token = localStorage.getItem('token');
let merchant = null;

const qs = (id) => document.getElementById(id);
const loginSection = qs('login-section');
const appSection = qs('app-section');

function setAuthUI() {
  if (token) {
    loginSection.classList.add('hidden');
    appSection.classList.remove('hidden');
    loadAll();
  } else {
    loginSection.classList.remove('hidden');
    appSection.classList.add('hidden');
  }
}

async function api(path, opts = {}) {
  const headers = { 'Content-Type': 'application/json', ...(opts.headers || {}) };
  if (token) headers.Authorization = `Bearer ${token}`;
  const res = await fetch(`${API}${path}`, { ...opts, headers });
  if (!res.ok) throw new Error(await res.text());
  return res.json();
}

qs('login-btn').onclick = async () => {
  const email = qs('email').value;
  const password = qs('password').value;
  try {
    const data = await api('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
    token = data.token;
    localStorage.setItem('token', token);
    setAuthUI();
  } catch (e) {
    qs('login-error').innerText = 'Login failed';
  }
};

qs('logout-btn').onclick = () => {
  token = null;
  localStorage.removeItem('token');
  setAuthUI();
};

async function loadAll() {
  await loadMerchant();
  await loadServices();
  await loadOrders();
  await loadRooms();
}

async function loadMerchant() {
  const data = await api('/merchants/my');
  merchant = data[0];
  if (!merchant) return;
  qs('m-name').value = merchant.name || '';
  qs('m-eta').value = merchant.eta || '';
  qs('m-price').value = merchant.price_range || '';
  qs('m-hours').value = merchant.hours || '';
}

qs('save-merchant').onclick = async () => {
  if (!merchant) return;
  const body = {
    name: qs('m-name').value,
    eta: qs('m-eta').value,
    price_range: qs('m-price').value,
    hours: qs('m-hours').value,
  };
  await api(`/merchants/${merchant.id}`, {
    method: 'PUT',
    body: JSON.stringify(body),
  });
  alert('Saved');
};

async function loadServices() {
  if (!merchant) return;
  const list = await api(`/services/merchant/${merchant.id}`);
  const ul = qs('services-list');
  ul.innerHTML = '';
  list.forEach((s) => {
    const li = document.createElement('li');
    li.innerText = `${s.name} - $${s.price}`;
    ul.appendChild(li);
  });
}

qs('add-service').onclick = async () => {
  if (!merchant) return;
  const body = {
    name: qs('s-name').value,
    description: qs('s-desc').value,
    price: Number(qs('s-price').value || 0),
  };
  await api(`/services/merchant/${merchant.id}`, {
    method: 'POST',
    body: JSON.stringify(body),
  });
  qs('s-name').value = '';
  qs('s-desc').value = '';
  qs('s-price').value = '';
  loadServices();
};

async function loadOrders() {
  const list = await api('/orders/merchant');
  const ul = qs('orders-list');
  ul.innerHTML = '';
  list.forEach((o) => {
    const li = document.createElement('li');
    li.innerText = `#${o.id} - ${o.status} - $${o.total}`;
    ul.appendChild(li);
  });
}

async function loadRooms() {
  const rooms = await api('/chat/rooms');
  const select = qs('rooms-select');
  select.innerHTML = '';
  rooms.forEach((r) => {
    const opt = document.createElement('option');
    opt.value = r.id;
    opt.text = `Room ${r.id}`;
    select.appendChild(opt);
  });
}

qs('load-messages').onclick = async () => {
  const roomId = qs('rooms-select').value;
  if (!roomId) return;
  const msgs = await api(`/chat/rooms/${roomId}/messages`);
  const box = qs('messages');
  box.innerHTML = msgs.map(m => `<div>${m.text}</div>`).join('');
};

qs('send-msg').onclick = async () => {
  const roomId = qs('rooms-select').value;
  const text = qs('msg-text').value;
  if (!roomId || !text) return;
  await api(`/chat/rooms/${roomId}/messages`, {
    method: 'POST',
    body: JSON.stringify({ text }),
  });
  qs('msg-text').value = '';
  qs('load-messages').click();
};

setAuthUI();
