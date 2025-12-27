const mongoose = require("mongoose");

const DataSchema = new mongoose.Schema({
  cropName: { type: String, required: true },
  yieldAmount: { type: Number, required: true },
  location: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Data", DataSchema);
