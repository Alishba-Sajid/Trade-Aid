// routes/communityRoutes.js
const express = require("express");
const router = express.Router();
const pool = require("../config/db");
const haversine = require("haversine-distance");

// ✅ GET nearby communities (within 2 km)
router.get("/", async (req, res) => {
  try {
    const { lat, lon } = req.query;
    if (!lat || !lon)
      return res.status(400).json({ error: "Latitude and longitude required" });

    const userLat = parseFloat(lat);
    const userLon = parseFloat(lon);

    const all = await pool.query("SELECT * FROM communities");
    const nearby = all.rows.filter(c => {
      const distance = haversine(
        { lat: userLat, lon: userLon },
        { lat: c.lat, lon: c.lon }
      );
      return distance <= 2000;
    });

    res.status(200).json(nearby);
  } catch (err) {
    console.error("Error fetching nearby communities:", err);
    res.status(500).json({ error: "Server error" });
  }
});



// ✅ Create a new community
// ✅ POST create a new community at /api/community
router.post("/community", async (req, res) => {
  try {
    const { name, description, lat, lon } = req.body;
    if (!name || !description || !lat || !lon) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const userLat = parseFloat(lat);
    const userLon = parseFloat(lon);

    // Check for existing nearby community
    const communities = await pool.query("SELECT * FROM communities");
    for (const c of communities.rows) {
      const dist = haversine(
        { lat: userLat, lon: userLon },
        { lat: c.lat, lon: c.lon }
      );
      if (dist <= 2000) {
        return res.status(409).json({
          message: "Community already exists nearby",
          existing: c,
        });
      }
    }

    const result = await pool.query(
      "INSERT INTO communities (name, description, lat, lon) VALUES ($1, $2, $3, $4) RETURNING *",
      [name, description, userLat, userLon]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error("Error creating community:", err);
    res.status(500).json({ error: "Server error" });
  }
});


// ✅ Join a community
router.post("/join", async (req, res) => {
  try {
    const { user_id, community_id } = req.body;

    if (!user_id || !community_id) {
      return res.status(400).json({ error: "Missing user_id or community_id" });
    }

    // Check if already requested
    const existing = await pool.query(
      "SELECT * FROM join_requests WHERE user_id=$1 AND community_id=$2",
      [user_id, community_id]
    );

    if (existing.rows.length > 0) {
      return res.status(409).json({ message: "Already requested to join" });
    }

    // Create join request
    const result = await pool.query(
      `INSERT INTO join_requests (user_id, community_id, status, approvals, rejections)
       VALUES ($1, $2, 'pending', 0, 0) RETURNING *`,
      [user_id, community_id]
    );

    res.status(201).json({
      message: "Join request submitted. Waiting for 60% approval.",
      request: result.rows[0],
    });
  } catch (err) {
    console.error("Error creating join request:", err);
    res.status(500).json({ error: "Server error" });
  }
});

module.exports = router;
