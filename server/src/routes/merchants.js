const express = require('express');
const db = require('../db');
const { auth, requireRole } = require('../middleware/auth');

const router = express.Router();

router.get('/', async (_req, res) => {
  const result = await db.query('SELECT * FROM merchants ORDER BY id');
  return res.json(result.rows);
});

router.get('/my', auth, requireRole('merchant', 'admin'), async (req, res) => {
  const result = await db.query(
    'SELECT * FROM merchants WHERE owner_user_id=$1 ORDER BY id',
    [req.user.id]
  );
  return res.json(result.rows);
});

router.get('/:id', async (req, res) => {
  const result = await db.query('SELECT * FROM merchants WHERE id=$1', [req.params.id]);
  if (!result.rows[0]) return res.status(404).json({ error: 'Not found' });
  return res.json(result.rows[0]);
});

router.put('/:id', auth, requireRole('merchant', 'admin'), async (req, res) => {
  const { name, latitude, longitude, rating, price_range, eta, image_url, hours } = req.body;
  const result = await db.query(
    `UPDATE merchants SET
      name=COALESCE($1,name),
      latitude=COALESCE($2,latitude),
      longitude=COALESCE($3,longitude),
      rating=COALESCE($4,rating),
      price_range=COALESCE($5,price_range),
      eta=COALESCE($6,eta),
      image_url=COALESCE($7,image_url),
      hours=COALESCE($8,hours)
     WHERE id=$9 RETURNING *`,
    [name, latitude, longitude, rating, price_range, eta, image_url, hours, req.params.id]
  );
  return res.json(result.rows[0]);
});

module.exports = router;
