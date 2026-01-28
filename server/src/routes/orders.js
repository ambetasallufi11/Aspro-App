const express = require('express');
const db = require('../db');
const { auth, requireRole } = require('../middleware/auth');

const router = express.Router();

router.post('/', auth, requireRole('user', 'admin'), async (req, res) => {
  const { merchant_id, items } = req.body; // items: [{service_id, qty}]
  if (!merchant_id || !Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ error: 'Missing items' });
  }

  // fetch prices
  const ids = items.map(i => i.service_id);
  const services = await db.query(
    `SELECT id, price FROM services WHERE id = ANY($1::int[])`,
    [ids]
  );
  const priceMap = new Map(services.rows.map(s => [s.id, Number(s.price)]));
  const total = items.reduce((sum, i) => sum + (priceMap.get(i.service_id) || 0) * (i.qty || 1), 0);

  const orderRes = await db.query(
    'INSERT INTO orders (user_id, merchant_id, status, total) VALUES ($1,$2,$3,$4) RETURNING *',
    [req.user.id, merchant_id, 'pending', total]
  );
  const order = orderRes.rows[0];

  for (const item of items) {
    const price = priceMap.get(item.service_id) || 0;
    await db.query(
      'INSERT INTO order_items (order_id, service_id, qty, price) VALUES ($1,$2,$3,$4)',
      [order.id, item.service_id, item.qty || 1, price]
    );
  }

  return res.json(order);
});

router.get('/', auth, requireRole('user', 'admin'), async (req, res) => {
  const result = await db.query('SELECT * FROM orders WHERE user_id=$1 ORDER BY created_at DESC', [req.user.id]);
  return res.json(result.rows);
});

router.get('/merchant', auth, requireRole('merchant', 'admin'), async (req, res) => {
  if (req.user.role === 'admin') {
    const result = await db.query('SELECT * FROM orders ORDER BY created_at DESC');
    return res.json(result.rows);
  }
  const result = await db.query(
    'SELECT * FROM orders WHERE merchant_id IN (SELECT id FROM merchants WHERE owner_user_id=$1) ORDER BY created_at DESC',
    [req.user.id]
  );
  return res.json(result.rows);
});

router.get('/admin', auth, requireRole('admin'), async (_req, res) => {
  const result = await db.query('SELECT * FROM orders ORDER BY created_at DESC');
  return res.json(result.rows);
});

router.patch('/:id/status', auth, requireRole('merchant', 'admin'), async (req, res) => {
  const { status } = req.body;
  const result = await db.query('UPDATE orders SET status=$1 WHERE id=$2 RETURNING *', [status, req.params.id]);
  return res.json(result.rows[0]);
});

module.exports = router;
