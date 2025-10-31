// server.js
const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const path = require("path");
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(bodyParser.json());

// Auth middleware (optional example)
const { authenticate } = require('./middleware/authMiddleware');

// Example protected route
app.get('/api/protected', authenticate, (req, res) => {
  res.json({ hello: 'only for logged in', user: req.user });
});

// Serve static uploads
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// ✅ Import Routes
const userRoutes = require("./routes/userRoutes");
const communityRoutes = require("./routes/communityRoutes");
const authRoutes = require('./routes/authRoutes');

// ✅ Mount routes (plural 'communities')
app.use('/api/auth', authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/communities", communityRoutes);

// Root check
app.get("/", (req, res) => {
  res.send("🌍 API is running! Try /api/community?lat=33.6844&lon=73.0479");
});

// Start server
app.listen(PORT, () => console.log(`🚀 Server running at http://localhost:${PORT}`));
