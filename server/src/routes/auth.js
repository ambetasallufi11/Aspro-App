const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../db');

const router = express.Router();

router.post('/register', async (req, res) => {
  const { name, email, password, phone, role } = req.body;
  if (!name || !email || !password) {
    return res.status(400).json({ error: 'Missing fields' });
  }

  const hashed = await bcrypt.hash(password, 10);
  try {
    const result = await db.query(
      'INSERT INTO users (name, email, password, phone, role) VALUES ($1,$2,$3,$4,$5) RETURNING id, name, email, role',
      [name, email.toLowerCase(), hashed, phone || null, role || 'user']
    );
    const user = result.rows[0];
    const token = jwt.sign(user, process.env.JWT_SECRET, { expiresIn: '7d' });
    return res.json({ user, token });
  } catch (err) {
    return res.status(400).json({ error: 'Email already exists' });
  }
});

router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Missing fields' });
  }

  const result = await db.query('SELECT * FROM users WHERE email=$1', [email.toLowerCase()]);
  const user = result.rows[0];
  if (!user) return res.status(401).json({ error: 'Invalid credentials' });

  const ok = await bcrypt.compare(password, user.password);
  if (!ok) return res.status(401).json({ error: 'Invalid credentials' });

  const payload = { id: user.id, name: user.name, email: user.email, role: user.role };
  const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '7d' });
  return res.json({ user: payload, token });
});

module.exports = router;
