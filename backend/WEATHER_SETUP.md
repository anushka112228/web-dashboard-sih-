# Weather and Agromonitoring API Setup Guide

## Overview
The backend now automatically retrieves weather and agromonitoring data for all farms. The system:
- Fetches current weather data from OpenWeatherMap API
- Retrieves agricultural monitoring data from Agromonitoring API
- Automatically updates weather data every 6 hours (configurable)
- Stores weather history in the database

## Configuration

### 1. Environment Variables
Add the following environment variables to your `.env` file:

```env
# OpenWeatherMap API Key (Get from https://openweathermap.org/api)
OPENWEATHER_API_KEY=9ce2218fcaa4e021e7b5015bc8224624

# Agromonitoring API Key (Get from https://agromonitoring.com/api)
AGROMONITORING_API_KEY=3eac96005f178498c6e7117a7123fda1

# Weather update interval in hours (default: 6)
WEATHER_UPDATE_INTERVAL_HOURS=6
```

### 2. Database Migration
You need to create a migration for the new `weather_data` table. Run:

```bash
# If using Alembic
alembic revision --autogenerate -m "Add weather_data table"
alembic upgrade head

# Or manually create the table using SQL:
```

```sql
CREATE TABLE weather_data (
    id SERIAL PRIMARY KEY,
    farm_id INTEGER REFERENCES farms(id),
    latitude FLOAT NOT NULL,
    longitude FLOAT NOT NULL,
    temperature FLOAT,
    humidity FLOAT,
    pressure FLOAT,
    wind_speed FLOAT,
    wind_direction FLOAT,
    precipitation FLOAT,
    uv_index FLOAT,
    visibility FLOAT,
    weather_description VARCHAR,
    weather_icon VARCHAR,
    forecast_data JSONB,
    agromonitoring_data JSONB,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_weather_data_farm_id ON weather_data(farm_id);
CREATE INDEX idx_weather_data_recorded_at ON weather_data(recorded_at);
```

## API Endpoints

### Get Weather for Farm
```
GET /api/v1/weather/farm/{farm_id}
```
Returns the latest weather data for a specific farm.

### Get Weather History
```
GET /api/v1/weather/farm/{farm_id}/history?days=7
```
Returns weather history for a farm (default: 7 days, max: 30 days).

### Manually Fetch Weather for Farm
```
POST /api/v1/weather/fetch/{farm_id}
```
Manually triggers weather data fetch for a specific farm.

### Manually Fetch Weather for All Farms
```
POST /api/v1/weather/fetch-all
```
Manually triggers weather data fetch for all user's farms.

## Automatic Updates

The system automatically updates weather data:
- **On startup**: Immediately fetches weather for all farms
- **Periodically**: Every 6 hours (configurable via `WEATHER_UPDATE_INTERVAL_HOURS`)

The background task runs asynchronously and logs all activities.

## Getting API Keys

### OpenWeatherMap
1. Go to https://openweathermap.org/api
2. Sign up for a free account
3. Navigate to API keys section
4. Copy your API key

### Agromonitoring
1. Go to https://agromonitoring.com/api
2. Sign up for an account
3. Get your API key from the dashboard

**Note**: If API keys are not configured, the system will log warnings but continue to function. The agromonitoring service will return mock data if the API is unavailable.

## Testing

After setting up, you can test the endpoints:

```bash
# Get weather for a farm (requires authentication)
curl -X GET "http://localhost:8000/api/v1/weather/farm/1" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Manually trigger weather fetch
curl -X POST "http://localhost:8000/api/v1/weather/fetch/1" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Troubleshooting

1. **No weather data**: Ensure farms have valid geometry (GeoJSON polygon)
2. **API errors**: Check API keys are correct and have sufficient quota
3. **Background task not running**: Check server logs for errors
4. **Database errors**: Ensure the `weather_data` table exists

