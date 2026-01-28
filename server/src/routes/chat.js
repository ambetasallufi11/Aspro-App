const express = require('express');
const db = require('../db');
const { auth, requireRole } = require('../middleware/auth');

const router = express.Router();

router.post('/rooms', auth, requireRole('user', 'admin'), async (req, res) => {
  const { merchant_id } = req.body;
  if (!merchant_id) return res.status(400).json({ error: 'Missing merchant_id' });

  const existing = await db.query(
    'SELECT * FROM chat_rooms WHERE user_id=$1 AND merchant_id=$2 AND is_support=false',
    [req.user.id, merchant_id]
  );
  if (existing.rows[0]) return res.json(existing.rows[0]);

  const result = await db.query(
    'INSERT INTO chat_rooms (user_id, merchant_id, is_support) VALUES ($1,$2,false) RETURNING *',
    [req.user.id, merchant_id]
  );
  return res.json(result.rows[0]);
});

router.post('/support', auth, requireRole('user', 'admin'), async (req, res) => {
  const existing = await db.query(
    'SELECT * FROM chat_rooms WHERE user_id=$1 AND is_support=true',
    [req.user.id]
  );
  if (existing.rows[0]) return res.json(existing.rows[0]);

  const result = await db.query(
    'INSERT INTO chat_rooms (user_id, merchant_id, is_support) VALUES ($1,NULL,true) RETURNING *',
    [req.user.id]
  );
  return res.json(result.rows[0]);
});

router.get('/rooms', auth, async (req, res) => {
  if (req.user.role === 'admin') {
    const result = await db.query(
      `SELECT cr.*, m.name AS merchant_name, m.image_url AS merchant_image_url, u.name AS user_name
       FROM chat_rooms cr
       LEFT JOIN merchants m ON cr.merchant_id=m.id
       JOIN users u ON cr.user_id=u.id`
    );
    return res.json(result.rows);
  }
  if (req.user.role === 'merchant') {
    const result = await db.query(
      `SELECT cr.*, u.name AS user_name
       FROM chat_rooms cr
       JOIN merchants m ON cr.merchant_id=m.id
       JOIN users u ON cr.user_id=u.id
       WHERE m.owner_user_id=$1 AND cr.is_support=false`,
      [req.user.id]
    );
    return res.json(result.rows);
  }

  const result = await db.query(
    `SELECT cr.*, m.name AS merchant_name, m.image_url AS merchant_image_url
     FROM chat_rooms cr
     LEFT JOIN merchants m ON cr.merchant_id=m.id
     WHERE cr.user_id=$1`,
    [req.user.id]
  );
  return res.json(result.rows);
});

router.get('/rooms/:id/messages', auth, async (req, res) => {
  const result = await db.query('SELECT * FROM messages WHERE room_id=$1 ORDER BY created_at ASC', [req.params.id]);
  return res.json(result.rows);
});

router.post('/rooms/:id/messages', auth, async (req, res) => {
  const { text } = req.body;
  if (!text) return res.status(400).json({ error: 'Missing text' });

  const msg = await db.query(
    'INSERT INTO messages (room_id, sender_user_id, text) VALUES ($1,$2,$3) RETURNING *',
    [req.params.id, req.user.id, text]
  );

  return res.json(msg.rows[0]);
});

module.exports = router;
