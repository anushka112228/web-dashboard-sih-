import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// --- SUB-MODELS FOR SPECIFIC DATA ---
class SoilHealth {
  final String nitrogen;   // Low, Medium, High, Optimal
  final String phosphorus;
  final String potassium;
  final String pH;

  SoilHealth(this.nitrogen, this.phosphorus, this.potassium, this.pH);
}

class MarketData {
  final double price; // per Quintal
  final String trend; // Rising, Falling, Stable
  final double change; // Amount changed

  MarketData(this.price, this.trend, this.change);
}

class Task {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String badge;
  final bool isMoney;
  final String popupTitle;
  final String popupBody;
  final String source;
  final bool isVerified;

  Task({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.badge,
    this.isMoney = false,
    required this.popupTitle,
    required this.popupBody,
    this.source = "AgriSense AI",
    this.isVerified = true,
  });
}

class CropInfo {
  final String name;
  final String stage;
  final double progress;
  final String days;
  final bool isHealthy;
  final String healthIssue;
  final List<Task> tasks;
  final List<double> yieldHistory; 
  final double predictedYield;     
  final String weatherType;
  
  // --- NEW FIELDS FOR SIDEBAR ---
  final String sowingDate;
  final String harvestDate;
  final SoilHealth soilHealth;
  final MarketData marketData;

  CropInfo({
    required this.name,
    required this.stage,
    required this.progress,
    required this.days,
    required this.isHealthy,
    this.healthIssue = "",
    required this.tasks,
    required this.yieldHistory,
    required this.predictedYield,
    required this.weatherType,
    required this.sowingDate,
    required this.harvestDate,
    required this.soilHealth,
    required this.marketData,
  });
}

class CropData {
  // Default fallback
  static final CropInfo _default = CropInfo(
    name: "Crop", stage: "Growth", progress: 0.5, days: "Day 30", isHealthy: true,
    tasks: [], yieldHistory: [10, 11, 12], predictedYield: 14, weatherType: "Sunny",
    sowingDate: "01 Jan 2024", harvestDate: "01 Apr 2024",
    soilHealth: SoilHealth("Medium", "Medium", "Medium", "6.5"),
    marketData: MarketData(2000, "Stable", 0),
  );

  static final Map<String, CropInfo> _data = {
    // --- 1. PADDY (Rice) ---
    "Paddy (Rice)": CropInfo(
      name: "Paddy (Rice)",
      stage: "Vegetative Stage",
      progress: 0.4,
      days: "Day 45 of 120",
      isHealthy: true,
      yieldHistory: [35, 38, 36, 40, 42],
      predictedYield: 45.5,
      weatherType: "Rainy",
      sowingDate: "15 June 2024",
      harvestDate: "15 Oct 2024",
      soilHealth: SoilHealth("Low", "Optimal", "High", "5.8"), // Needs Urea
      marketData: MarketData(2150, "Rising", 25), // +25 Rs
      tasks: [
        Task(
          title: "Irrigate 200L",
          subtitle: "Soil moisture low (45%)",
          icon: FontAwesomeIcons.droplet,
          color: Colors.blue,
          badge: "Critical",
          popupTitle: "Irrigation Alert",
          popupBody: "Paddy requires standing water of 2-5cm at this stage. Your soil sensor indicates moisture has dropped.",
          source: "Soil Sensor #1",
        ),
        Task(
          title: "Check Stem Borer",
          subtitle: "Risk: High",
          icon: FontAwesomeIcons.bug,
          color: Colors.orange,
          badge: "Advisory",
          popupTitle: "Pest Warning",
          popupBody: "Humid weather detected. Look for 'Dead Hearts'. Apply Chlorantraniliprole if needed.",
          source: "Agri-Weather AI",
        ),
      ],
    ),

    // --- 2. WHEAT ---
    "Wheat": CropInfo(
      name: "Wheat",
      stage: "Crown Root Initiation",
      progress: 0.3,
      days: "Day 25 of 120",
      isHealthy: false, 
      healthIssue: "Yellow Rust Detected",
      yieldHistory: [18, 20, 19, 21, 18],
      predictedYield: 16.5,
      weatherType: "Sunny",
      sowingDate: "10 Nov 2023",
      harvestDate: "20 Mar 2024",
      soilHealth: SoilHealth("Optimal", "Medium", "Optimal", "7.0"),
      marketData: MarketData(2275, "Falling", -10),
      tasks: [
        Task(
          title: "Spray Propiconazole",
          subtitle: "Rust pustules found",
          icon: FontAwesomeIcons.sprayCan,
          color: Colors.red,
          badge: "Urgent",
          popupTitle: "Yellow Rust Management",
          popupBody: "Yellow Rust detected. Spray Propiconazole 25 EC immediately.",
          source: "Drone Survey #9",
        ),
      ],
    ),

    // --- 3. POTATO ---
    "Potato": CropInfo(
      name: "Potato",
      stage: "Tuber Bulking",
      progress: 0.60,
      days: "Day 55 of 90",
      isHealthy: true,
      yieldHistory: [80, 85, 90, 88, 92],
      predictedYield: 95.0,
      weatherType: "Sunny",
      sowingDate: "20 Oct 2023",
      harvestDate: "20 Jan 2024",
      soilHealth: SoilHealth("High", "High", "Low", "6.0"), // Potash needed
      marketData: MarketData(1200, "Rising", 50),
      tasks: [
        Task(
          title: "Check Late Blight",
          subtitle: "Cloudy weather alert",
          icon: FontAwesomeIcons.cloudRain,
          color: Colors.red,
          badge: "Disease Risk",
          popupTitle: "Late Blight Warning",
          popupBody: "Cool weather favors Late Blight. Prophylactic spray of Mancozeb is recommended.",
          source: "Weather Station",
        ),
      ],
    ),

    // --- 4. SUGARCANE ---
    "Sugarcane": CropInfo(
      name: "Sugarcane",
      stage: "Grand Growth",
      progress: 0.5,
      days: "Month 6 of 12",
      isHealthy: true,
      yieldHistory: [300, 310, 305, 320, 330],
      predictedYield: 340.0,
      weatherType: "Cloudy",
      sowingDate: "15 Jan 2023",
      harvestDate: "15 Jan 2024",
      soilHealth: SoilHealth("Medium", "Optimal", "Medium", "7.2"),
      marketData: MarketData(290, "Stable", 0), // FRP often stable
      tasks: [
        Task(
          title: "Propping",
          subtitle: "Prevent lodging",
          icon: FontAwesomeIcons.textHeight,
          color: Colors.green,
          badge: "Operation",
          popupTitle: "Crop Propping",
          popupBody: "Tie plants together to prevent lodging during upcoming winds.",
          source: "Calendar",
        ),
      ],
    ),
  };

  static CropInfo get(String cropName) {
    return _data[cropName] ?? _default;
  }
}