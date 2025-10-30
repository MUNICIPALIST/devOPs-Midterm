const express = require('express');
const { Pool } = require('pg');
const path = require('path');

const app = express();
const port = 3001;

const pool = new Pool({
  host: '167.71.42.212',
  user: 'postgres',
  database: 'devops_lab',
  password: '1234',
  port: 5432,
});

app.use(express.static(path.join(__dirname)));

app.get('/api/users', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM users ORDER BY id');
    res.json(result.rows);
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).json({ error: 'Failed to fetch users from database' });
  }
});

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

pool.on('connect', () => {
  console.log('Connected to PostgreSQL database');
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
  process.exit(-1);
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
  console.log('Access the application at: http://localhost:3000');
});
