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

let merchant = null;

async function loadMerchant() {
  const list = await api('/merchants/my');
  merchant = list[0];
  if (!merchant) return;
  qs('m-name').value = merchant.name || '';
  qs('m-eta').value = merchant.eta || '';
  qs('m-price').value = merchant.price_range || '';
  qs('m-hours').value = merchant.hours || '';
}

qs('save-merchant').onclick = async () => {
  if (!merchant) return;
  await api(`/merchants/${merchant.id}`, {
    method: 'PUT',
    body: JSON.stringify({
      name: qs('m-name').value,
      eta: qs('m-eta').value,
      price_range: qs('m-price').value,
      hours: qs('m-hours').value,
    }),
  });
  alert('Saved');
};

async function loadServices() {
  if (!merchant) return;
  const services = await api(`/services/merchant/${merchant.id}`);
  const container = qs('services');
  container.innerHTML = services.map(s => `
    <div class="row between">
      <div>
        <strong>${s.name}</strong><br/>
        <span class="muted">${s.description || ''}</span>
      </div>
      <div>$${s.price}</div>
    </div>
  `).join('');
}

qs('add-service').onclick = async () => {
  if (!merchant) return;
  await api(`/services/merchant/${merchant.id}`, {
    method: 'POST',
    body: JSON.stringify({
      name: qs('s-name').value,
      description: qs('s-desc').value,
      price: Number(qs('s-price').value || 0),
    }),
  });
  qs('s-name').value = '';
  qs('s-desc').value = '';
  qs('s-price').value = '';
  loadServices();
};

async function loadOrders() {
  const orders = await api('/orders/merchant');
  const container = qs('orders');
  const statuses = ['pending','picked up','washing','ready','delivered'];
  container.innerHTML = orders.map(o => `
    <div class="row between">
      <div>
        <strong>#${o.id}</strong><br/>
        <span class="muted">$${o.total}</span>
      </div>
      <select data-id="${o.id}">
        ${statuses.map(s => `<option ${o.status===s?'selected':''}>${s}</option>`).join('')}
      </select>
    </div>
  `).join('');

  container.querySelectorAll('select').forEach(sel => {
    sel.onchange = async () => {
      const id = sel.getAttribute('data-id');
      await api(`/orders/${id}/status`, {
        method: 'PATCH',
        body: JSON.stringify({ status: sel.value }),
      });
    };
  });
}

async function loadRooms() {
  const rooms = await api('/chat/rooms');
  const select = qs('rooms');
  select.innerHTML = rooms.map(r => `<option value="${r.id}">Room ${r.id} - ${r.user_name || ''}</option>`).join('');
}

qs('load-messages').onclick = async () => {
  const roomId = qs('rooms').value;
  if (!roomId) return;
  const msgs = await api(`/chat/rooms/${roomId}/messages`);
  qs('messages').innerHTML = msgs.map(m => `<div>${m.text}</div>`).join('');
};

qs('send-msg').onclick = async () => {
  const roomId = qs('rooms').value;
  const text = qs('msg-text').value;
  if (!roomId || !text) return;
  await api(`/chat/rooms/${roomId}/messages`, {
    method: 'POST',
    body: JSON.stringify({ text }),
  });
  qs('msg-text').value = '';
  qs('load-messages').click();
};

(async function init() {
  await loadMerchant();
  await loadServices();
  await loadOrders();
  await loadRooms();
})();
