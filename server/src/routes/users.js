const express = require('express');
const db = require('../db');
const { auth } = require('../middleware/auth');

const router = express.Router();

router.get('/me', auth, async (req, res) => {
  const userRes = await db.query(
    'SELECT id, name, email, phone, role FROM users WHERE id=$1',
    [req.user.id]
  );
  const addrRes = await db.query('SELECT address FROM addresses WHERE user_id=$1', [req.user.id]);
  return res.json({ ...userRes.rows[0], addresses: addrRes.rows.map(r => r.address) });
});

module.exports = router;
