const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const pool = require('./db');

const app = express();
const PORT = 3000;

// 🧩 Middleware
app.use(cors());
app.use(bodyParser.json());

// 📥 Registration API
app.post('/register', async (req, res) => {
  const { name, email, password, phone } = req.body;

  try {
    const result = await pool.query(
      'INSERT INTO users (name, email, password, phone) VALUES ($1, $2, $3, $4) RETURNING *',
      [name, email, password, phone]
    );

    res.status(201).json({
      message: 'User registered successfully',
      user: result.rows[0],
    });
  } catch (err) {
    console.error('❌ Database Error (Register):', err);
    res.status(500).json({ error: 'Database error during registration' });
  }
});


// 🔑 Login API
app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  // Simple validation
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  try {
    const result = await pool.query(
      'SELECT * FROM users WHERE email = $1 AND password = $2',
      [email, password]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // ✅ Successful login
    const user = result.rows[0];
    res.status(200).json({
      message: 'Login successful',
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
      },
    });
  } catch (err) {
    console.error('❌ Database Error (Login):', err);
    res.status(500).json({ error: 'Database error during login' });
  }
});
// Create Community
// 📦 Community Creation API
app.post('/community', async (req, res) => {
  const { name, description, created_by } = req.body;

  try {
    const result = await pool.query(
      'INSERT INTO communities (name, description, latitude, longitude, created_by) VALUES ($1, $2, 0.0, 0.0, $3) RETURNING *',
      [name, description, created_by]
    );

    res.status(201).json({
      message: 'Community created successfully',
      community: result.rows[0],
    });
  } catch (err) {
    console.error('❌ Database Error:', err);
    res.status(500).json({ error: 'Database error' });
  }
});


// Get all communities (admin)
app.get('/communities', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM communities ORDER BY created_at DESC');
    res.status(200).json(result.rows);
  } catch (err) {
    console.error('DB Error (fetch communities):', err);
    res.status(500).json({ error: 'Database error' });
  }
});



// 🏃 Start the server
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
