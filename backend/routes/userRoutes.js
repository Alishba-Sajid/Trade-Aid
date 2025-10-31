// routes/userRoutes.js
const express = require("express");
const multer = require("multer");
const pool = require("../config/db");
const bcrypt = require("bcryptjs");

const router = express.Router();

// ⚙️ Multer configuration for profile picture uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, "uploads/"),
  filename: (req, file, cb) => cb(null, Date.now() + "-" + file.originalname),
});
const upload = multer({ storage });

/* ============================================================
   🧩 REGISTER USER
   Endpoint: POST /api/users/register
   Description: Creates a new user with email + password.
   Inserts into 'password_hash' (not 'password').
   ============================================================ */
router.post("/register", async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password)
      return res.status(400).json({ message: "Missing email or password" });

    // check if email already exists
    const existing = await pool.query("SELECT id FROM users WHERE email = $1", [
      email,
    ]);
    if (existing.rows.length > 0)
      return res
        .status(400)
        .json({ message: "Email already exists. Please log in." });

    // hash password and insert
    const hashedPassword = await bcrypt.hash(password, 10);
    const result = await pool.query(
      `INSERT INTO users (email, password_hash, profile_completed, created_at, updated_at)
       VALUES ($1, $2, false, now(), now())
       RETURNING id, email, profile_completed`,
      [email, hashedPassword]
    );

    return res.status(201).json({
      message: "User registered successfully",
      user: result.rows[0],
    });
  } catch (error) {
    console.error("❌ Register Error:", error);
    return res.status(500).json({
      message: "Internal Server Error",
      error: error.message,
    });
  }
});

/* ============================================================
   🧠 UPDATE PROFILE
   Endpoint: POST /api/users/profile
   Description: Updates user info + uploads profile picture.
   ============================================================ */
router.post("/profile", upload.single("profile_picture"), async (req, res) => {
  try {
    const { email, full_name, gender, address, phone } = req.body;
    const profile_picture = req.file ? req.file.filename : null;

    if (!email)
      return res.status(400).json({ message: "Missing email to identify user" });

    const result = await pool.query(
      `UPDATE users
       SET full_name = COALESCE(NULLIF($2, ''), full_name),
           gender = COALESCE(NULLIF($3, ''), gender),
           address = COALESCE(NULLIF($4, ''), address),
           phone = COALESCE(NULLIF($5, ''), phone),
           profile_picture = COALESCE($6, profile_picture),
           profile_completed = true,
           updated_at = now()
       WHERE email = $1
       RETURNING id, email, full_name, profile_completed`,
      [email, full_name, gender, address, phone, profile_picture]
    );

    if (result.rows.length === 0)
      return res.status(404).json({ message: "User not found" });

    return res.status(200).json({
      message: "Profile updated successfully",
      user: result.rows[0],
    });
  } catch (error) {
    console.error("❌ Profile Update Error:", error);
    return res.status(500).json({
      message: "Internal Server Error",
      error: error.message,
    });
  }
});

module.exports = router;
