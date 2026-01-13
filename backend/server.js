const express = require("express");
const cors = require("cors");
const bcrypt = require("bcryptjs");
const pool = require("./config/db");

const app = express();
const PORT = 5000;

// ✅ middleware (order matters)
app.use(cors({
  origin: "*",   // allow all origins (safe for dev)
  methods: ["GET", "POST"],
  allowedHeaders: ["Content-Type"]
}));
app.use(express.json()); // ❗ use built-in parser

// ✅ health check
app.get("/", (req, res) => {
  res.status(200).send("Backend + PostgreSQL running 🚀");
});

/* =======================
   REGISTER USER
======================= */
app.post("/api/register", async (req, res) => {
  try {
    const { name, email, password, phone_no } = req.body;

    // ✅ validation (prevents silent crash)
    if (!name || !email || !password) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    // check existing email
    const userExists = await pool.query(
      "SELECT id FROM users WHERE email = $1",
      [email]
    );

    if (userExists.rows.length > 0) {
      return res.status(409).json({ message: "Email already exists" });
    }

    // hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // insert user
    const newUser = await pool.query(
      `INSERT INTO users (name, email, password, phone_no)
       VALUES ($1, $2, $3, $4)
       RETURNING id, name, email, phone_no`,
      [name, email, hashedPassword, phone_no]
    );

    res.status(201).json({
      message: "User registered successfully",
      user: newUser.rows[0]
    });

  } catch (error) {
    console.error("Register Error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

/* =======================
   GET ALL USERS
======================= */
app.get("/api/users", async (req, res) => {
  try {
    const result = await pool.query(
      "SELECT id, name, email, phone_no FROM users"
    );
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Get Users Error:", error);
    res.status(500).json({ message: "Server error" });
  }
});
/* =======================
   LOGIN USER
======================= */
app.post("/api/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: "Email and password required" });
    }

    // check user
    const result = await pool.query(
      "SELECT * FROM users WHERE email = $1",
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    const user = result.rows[0];

    // compare password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    // success
    res.status(200).json({
      message: "Login successful",
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone_no: user.phone_no
      }
    });

  } catch (error) {
    console.error("Login Error:", error);
    res.status(500).json({ message: "Server error" });
  }
});


// ✅ start server
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
