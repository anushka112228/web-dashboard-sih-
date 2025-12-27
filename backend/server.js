// =====================
// server.js
// =====================
console.log("🔥 SERVER.JS IS RUNNING FROM BACKEND");

const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 5000;

// =====================
// Middlewares
// =====================
app.use(cors());
app.use(express.json());

// =====================
// Root route (optional)
// =====================
app.get("/", (req, res) => {
  res.send("Backend for Crop Yield Dashboard 🚀");
});

// =====================
// API Routes
// =====================
const dataRoutes = require("./routes/data");
app.use("/api/data", dataRoutes);
console.log("✅ Data routes loaded");


// =====================
// MongoDB Connection
// =====================
const MONGO_URI = process.env.MONGO_URI;

if (!MONGO_URI) {
  console.error("❌ MONGO_URI not found in .env. Exiting.");
  process.exit(1);
}

mongoose
  .connect(MONGO_URI)
  .then(() => console.log("MongoDB connected"))
  .catch((err) => console.log("MongoDB connection error:", err.message));

// =====================
// Start Server
// =====================
app.get("/api/data/test-direct", (req, res) => {
  res.json({ message: "DIRECT ROUTE WORKING ✅" });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
