import fs from 'node:fs';
import os from 'node:os';
import express from 'express';
import pg from 'pg';
import { createClient } from 'redis';

const PORT = process.env.PORT || 3000;
const HOST = os.hostname();

const pool = new pg.Pool({
  password: fs.readFileSync(process.env.PGPASSWORD_FILE, 'utf8').trim(),
});
// idle connections drop when the db container restarts; log it instead of crashing
pool.on('error', (err) => console.error('pg:', err.message));
const redis = createClient({ url: process.env.REDIS_URL });
redis.on('error', (err) => console.error('redis:', err.message));

const app = express();
app.use(express.json());

app.get('/api/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    await redis.ping();
    res.json({ status: 'ok', container: HOST, db: 'up', cache: 'up' });
  } catch (err) {
    res.status(503).json({ status: 'error', container: HOST, error: err.message });
  }
});

// every call increments a counter in Redis and reports which replica answered
app.get('/api/whoami', async (req, res) => {
  const visits = await redis.incr('visits');
  res.json({ container: HOST, visits });
});

app.get('/api/notes', async (req, res) => {
  const { rows } = await pool.query('SELECT id, text, created_by, created_at FROM notes ORDER BY id');
  res.json(rows);
});

app.post('/api/notes', async (req, res) => {
  const text = String(req.body?.text || '').trim();
  if (!text) return res.status(400).json({ error: 'text is required' });
  const { rows } = await pool.query(
    'INSERT INTO notes (text, created_by) VALUES ($1, $2) RETURNING id, text, created_by, created_at',
    [text, HOST],
  );
  res.status(201).json(rows[0]);
});

await redis.connect();
app.listen(PORT, () => console.log(`api ${HOST} listening on port ${PORT}`));
