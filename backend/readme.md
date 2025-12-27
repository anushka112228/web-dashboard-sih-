# 🌾 AgriSense – Crop Yield Monitoring Dashboard

AgriSense is a full-stack web dashboard built to help government officials monitor crop yield data, assess risks, and visualize agricultural trends at a district level.

## 🚀 Features
- Real-time crop data collection
- Interactive yield analytics (charts & graphs)
- Risk classification based on yield thresholds
- Geospatial visualization (map view)
- MongoDB-backed persistent storage

## 🛠 Tech Stack
**Frontend**
- React (Vite)
- Tailwind CSS
- Recharts
- Leaflet

**Backend**
- Node.js
- Express.js
- MongoDB
- Mongoose

## 📊 System Flow
1. User submits crop data via dashboard
2. Backend API stores data in MongoDB
3. Frontend fetches data in real time
4. Analytics & charts update dynamically

## 🧠 Key Engineering Concepts
- REST API design
- Frontend–Backend integration
- State management using React hooks
- Data visualization
- Modular backend architecture

## ▶️ How to Run Locally

### Backend
```bash
cd backend
npm install
node server.js
