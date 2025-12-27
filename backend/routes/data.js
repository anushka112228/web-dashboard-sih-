console.log("🔥 data.js ROUTE FILE LOADED");

const express = require("express");
const router = express.Router();
const Data = require("../models/Data");

// Test route
router.get("/test", (req, res) => {
  res.json({ message: "Data route working ✅" });
});

// Save crop yield data
router.post("/collect", async (req, res) => {
  try {
    const { cropName, yieldAmount, location } = req.body;
    if (!cropName || !yieldAmount || !location) {
      return res.status(400).json({ error: "Missing fields" });
    }
    const entry = new Data({ cropName, yieldAmount, location });
    await entry.save();
    res.status(201).json({ message: "Data saved", data: entry });
  } catch (err) {
    res.status(500).json({ error: "Server error" });
  }
});

// Fetch all data
router.get("/all", async (req, res) => {
  const data = await Data.find().sort({ createdAt: -1 });
  res.json(data);
});

module.exports = router;
