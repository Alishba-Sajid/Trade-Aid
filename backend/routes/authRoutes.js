const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const pool = require("../config/db");
require('dotenv').config();

const JWT_SECRET = process.env.JWT_SECRET || 'dev_secret';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';
const SALT_ROUNDS = 10;

// 🧾 Register a new user
router.post(
  '/register',
  [
    body('email').isEmail().withMessage('Invalid email'),
    body('password').isLength({ min: 4 }).withMessage('Password too short'),
    body('full_name').notEmpty().withMessage('Full name required'),
    body('gender').optional(),
    body('address').optional(),
    body('phone').optional(),
    body('profile').optional(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty())
      return res.status(400).json({ errors: errors.array() });

    try {
      const {
        email,
        password,
        full_name,
        gender,
        address,
        phone,
        profile,
      } = req.body;

      const existing = await pool.query(
        'SELECT id FROM users WHERE email = $1',
        [email]
      );
      if (existing.rows.length > 0)
        return res.status(409).json({ error: 'Email already registered' });

      const password_hash = await bcrypt.hash(password, SALT_ROUNDS);

      const result = await pool.query(
        `INSERT INTO users (
          email, password_hash, full_name, gender, address, phone, profile, profile_completed, created_at, updated_at
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, false, NOW(), NOW())
        RETURNING id, email, full_name, gender, address, phone, profile, profile_completed`,
        [email, password_hash, full_name, gender || null, address || null, phone || null, profile || null]
      );

      const user = result.rows[0];
      const token = jwt.sign(
        { id: user.id, email: user.email },
        JWT_SECRET,
        { expiresIn: JWT_EXPIRES_IN }
      );

      res.status(201).json({ user, token });
    } catch (err) {
      console.error('REGISTER ERROR:', err);
      res.status(500).json({ error: 'Server error' });
    }
  }
);

// 🔐 Login user
router.post(
  '/login',
  [body('email').isEmail(), body('password').notEmpty()],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty())
      return res.status(400).json({ errors: errors.array() });

    try {
      const { email, password } = req.body;

      const result = await pool.query(
        'SELECT * FROM users WHERE email = $1',
        [email]
      );

      if (result.rows.length === 0)
        return res.status(401).json({ error: 'Invalid credentials' });

      const user = result.rows[0];
      const match = await bcrypt.compare(password, user.password_hash);
      if (!match)
        return res.status(401).json({ error: 'Invalid credentials' });

      const token = jwt.sign(
        { id: user.id, email: user.email },
        JWT_SECRET,
        { expiresIn: JWT_EXPIRES_IN }
      );

      delete user.password_hash; // Don’t send password hash
      res.json({ user, token });
    } catch (err) {
      console.error('LOGIN ERROR:', err);
      res.status(500).json({ error: 'Server error' });
    }
  }
);

module.exports = router;
