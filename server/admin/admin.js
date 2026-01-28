const API = 'http://localhost:3000';
const token = localStorage.getItem('token');
if (!token) window.location.href = '/admin/index.html';

const qs = (id) => document.getElementById(id);

async function api(path, opts = {}) {
  const res = await fetch(`${API}${path}`, {
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
    ...opts,
  });
  if (!res.ok) throw new Error(await res.text());
  return res.json();
}

qs('logout').onclick = () => {
  localStorage.removeItem('token');
  localStorage.removeItem('role');
  window.location.href = '/admin/index.html';
};

async function loadMerchants() {
  const list = await api('/merchants');
  qs('merchants').innerHTML = list.map(m => `
    <div class="row between">
      <div><strong>${m.name}</strong> <span class="muted">#${m.id}</span></div>
      <div>${m.eta || ''}</div>
    </div>
  `).join('');
}

async function loadOrders() {
  const list = await api('/orders/admin');
  qs('orders').innerHTML = list.map(o => `
    <div class="row between">
      <div><strong>#${o.id}</strong> <span class="muted">${o.status}</span></div>
      <div>$${o.total}</div>
    </div>
  `).join('');
}

async function loadRooms() {
  const rooms = await api('/chat/rooms');
  qs('rooms').innerHTML = rooms.map(r => `
    <option value="${r.id}">Room ${r.id} - ${r.user_name || ''} / ${r.merchant_name || ''}</option>
  `).join('');
}

qs('load-messages').onclick = async () => {
  const roomId = qs('rooms').value;
  if (!roomId) return;
  const msgs = await api(`/chat/rooms/${roomId}/messages`);
  qs('messages').innerHTML = msgs.map(m => `<div>${m.text}</div>`).join('');
};

(async function init() {
  await loadMerchants();
  await loadOrders();
  await loadRooms();
})();
