const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const merchantRoutes = require('./routes/merchants');
const serviceRoutes = require('./routes/services');
const orderRoutes = require('./routes/orders');
const chatRoutes = require('./routes/chat');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/', (_req, res) => res.json({ ok: true }));

app.use('/auth', authRoutes);
app.use('/users', userRoutes);
app.use('/merchants', merchantRoutes);
app.use('/services', serviceRoutes);
app.use('/orders', orderRoutes);
app.use('/chat', chatRoutes);
app.use('/admin', express.static(path.join(__dirname, '../admin')));

const port = process.env.PORT || 3000;
app.listen(port, () => {
  console.log(`API running on http://localhost:${port}`);
});
