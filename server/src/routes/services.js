const express = require('express');
const db = require('../db');
const { auth, requireRole } = require('../middleware/auth');

const router = express.Router();

router.get('/', async (_req, res) => {
  const result = await db.query('SELECT * FROM services ORDER BY id');
  return res.json(result.rows);
});

router.get('/merchant/:id', async (req, res) => {
  const result = await db.query('SELECT * FROM services WHERE merchant_id=$1 ORDER BY id', [req.params.id]);
  return res.json(result.rows);
});

router.post('/merchant/:id', auth, requireRole('merchant', 'admin'), async (req, res) => {
  const { name, description, price } = req.body;
  if (!name || price == null) return res.status(400).json({ error: 'Missing fields' });
  const result = await db.query(
    'INSERT INTO services (merchant_id, name, description, price) VALUES ($1,$2,$3,$4) RETURNING *',
    [req.params.id, name, description || null, price]
  );
  return res.json(result.rows[0]);
});

router.patch('/:id', auth, requireRole('merchant', 'admin'), async (req, res) => {
  const { name, description, price, active } = req.body;
  const result = await db.query(
    `UPDATE services SET
      name=COALESCE($1,name),
      description=COALESCE($2,description),
      price=COALESCE($3,price),
      active=COALESCE($4,active)
     WHERE id=$5 RETURNING *`,
    [name, description, price, active, req.params.id]
  );
  return res.json(result.rows[0]);
});

module.exports = router;
