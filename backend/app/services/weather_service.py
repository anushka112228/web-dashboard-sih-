"""
Weather Service - Fetches weather data from OpenWeatherMap API
"""
import httpx
from typing import Dict, Any, Optional, List, Tuple
from app.core.config import settings
import logging
from datetime import datetime

logger = logging.getLogger(__name__)

class WeatherService:
    def __init__(self):
        self.api_key = settings.OPENWEATHER_API_KEY
        self.base_url = "https://api.openweathermap.org/data/2.5"
        self.district_coords: Dict[str, Tuple[float, float]] = {
            "angul": (20.8390, 85.0985),
            "balangir": (20.7074, 83.4870),
            "balasore": (21.5023, 86.9890),
            "bargarh": (21.3498, 83.6190),
            "bhadrak": (21.0570, 86.4961),
            "boudh": (20.8245, 84.3275),
            "cuttack": (20.4625, 85.8828),
            "deogarh": (21.5385, 84.7193),
            "dhenkanal": (20.6590, 85.5980),
            "gajapati": (19.1915, 84.1857),
            "ganjam": (19.3149, 84.7941),
            "jagatsinghpur": (20.2680, 86.1713),
            "jajpur": (20.8486, 86.3375),
            "jharsuguda": (21.8554, 84.0066),
            "kalahandi": (19.9137, 83.1649),
            "kandhamal": (20.4709, 84.2040),
            "kendrapara": (20.5000, 86.4167),
            "kendujhar": (21.6317, 85.5817),
            "khordha": (20.1852, 85.6136),
            "koraput": (18.8135, 82.7123),
            "malkangiri": (18.3433, 81.8901),
            "mayurbhanj": (21.9400, 86.7400),
            "nabarangpur": (19.2311, 82.5480),
            "nayagarh": (20.1295, 85.0961),
            "nuapada": (20.8287, 82.5796),
            "puri": (19.8135, 85.8312),
            "rayagada": (19.1713, 83.4108),
            "sambalpur": (21.4669, 83.9812),
            "subarnapur": (20.8333, 83.9167),
            "sundargarh": (22.1167, 84.0337),
        }
    
    async def get_current_weather(self, latitude: float, longitude: float) -> Optional[Dict[str, Any]]:
        """
        Fetch current weather data for given coordinates
        
        Args:
            latitude: Latitude of the location
            longitude: Longitude of the location
            
        Returns:
            Dictionary containing weather data or None if error
        """
        if not self.api_key:
            logger.warning("OpenWeatherMap API key not configured")
            return None
        
        try:
            url = f"{self.base_url}/weather"
            params = {
                "lat": latitude,
                "lon": longitude,
                "appid": self.api_key,
                "units": "metric"  # Get temperature in Celsius
            }
            
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.get(url, params=params)
                response.raise_for_status()
                data = response.json()
                
                # Extract relevant weather information
                weather_info = {
                    "temperature": data.get("main", {}).get("temp"),
                    "feels_like": data.get("main", {}).get("feels_like"),
                    "humidity": data.get("main", {}).get("humidity"),
                    "pressure": data.get("main", {}).get("pressure"),
                    "wind_speed": data.get("wind", {}).get("speed"),
                    "wind_direction": data.get("wind", {}).get("deg"),
                    "visibility": data.get("visibility"),
                    "uv_index": None,  # UV index requires separate API call
                    "precipitation": data.get("rain", {}).get("1h", 0) or data.get("rain", {}).get("3h", 0),
                    "weather_description": data.get("weather", [{}])[0].get("description", ""),
                    "weather_icon": data.get("weather", [{}])[0].get("icon", ""),
                    "clouds": data.get("clouds", {}).get("all", 0),
                    "sunrise": data.get("sys", {}).get("sunrise"),
                    "sunset": data.get("sys", {}).get("sunset"),
                    "raw_data": data  # Store full response for reference
                }
                
                return weather_info
                
        except httpx.HTTPError as e:
            logger.error(f"Error fetching weather data: {str(e)}")
            return None
        except Exception as e:
            logger.error(f"Unexpected error in weather service: {str(e)}")
            return None
    
    async def get_forecast(self, latitude: float, longitude: float, days: int = 5) -> Optional[Dict[str, Any]]:
        """
        Fetch weather forecast for given coordinates
        
        Args:
            latitude: Latitude of the location
            longitude: Longitude of the location
            days: Number of days to forecast (default: 5)
            
        Returns:
            Dictionary containing forecast data or None if error
        """
        if not self.api_key:
            logger.warning("OpenWeatherMap API key not configured")
            return None
        
        try:
            url = f"{self.base_url}/forecast"
            params = {
                "lat": latitude,
                "lon": longitude,
                "appid": self.api_key,
                "units": "metric",
                "cnt": days * 8  # 8 forecasts per day (3-hour intervals)
            }
            
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.get(url, params=params)
                response.raise_for_status()
                data = response.json()
                
                # Process forecast list
                forecast_list = []
                for item in data.get("list", [])[:days * 8]:
                    forecast_list.append({
                        "datetime": item.get("dt"),
                        "temperature": item.get("main", {}).get("temp"),
                        "humidity": item.get("main", {}).get("humidity"),
                        "pressure": item.get("main", {}).get("pressure"),
                        "wind_speed": item.get("wind", {}).get("speed"),
                        "precipitation": item.get("rain", {}).get("3h", 0),
                        "weather_description": item.get("weather", [{}])[0].get("description", ""),
                        "weather_icon": item.get("weather", [{}])[0].get("icon", "")
                    })
                
                return {
                    "forecast": forecast_list,
                    "city": data.get("city", {}).get("name", ""),
                    "country": data.get("city", {}).get("country", "")
                }
                
        except httpx.HTTPError as e:
            logger.error(f"Error fetching weather forecast: {str(e)}")
            return None
        except Exception as e:
            logger.error(f"Unexpected error in weather forecast service: {str(e)}")
            return None

    async def get_daily_forecast(self, latitude: float, longitude: float, days: int = 10) -> Optional[List[Dict[str, Any]]]:
        """
        Fetch daily forecast using Open-Meteo (no API key required)
        """
        try:
            url = "https://api.open-meteo.com/v1/forecast"
            params = {
                "latitude": latitude,
                "longitude": longitude,
                "daily": "weathercode,temperature_2m_max,temperature_2m_min,precipitation_sum",
                "forecast_days": min(max(days, 1), 16),
                "timezone": "Asia/Kolkata",
            }

            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.get(url, params=params)
                response.raise_for_status()
                data = response.json()

            daily = data.get("daily", {})
            times = daily.get("time", [])
            max_temps = daily.get("temperature_2m_max", [])
            min_temps = daily.get("temperature_2m_min", [])
            precip = daily.get("precipitation_sum", [])
            codes = daily.get("weathercode", [])

            forecast: List[Dict[str, Any]] = []
            for idx, date_str in enumerate(times):
                forecast.append({
                    "date": date_str,
                    "condition": self._map_weather_code(codes[idx] if idx < len(codes) else None),
                    "temp_max_c": max_temps[idx] if idx < len(max_temps) else None,
                    "temp_min_c": min_temps[idx] if idx < len(min_temps) else None,
                    "precipitation_mm": precip[idx] if idx < len(precip) else 0,
                    "weather_code": codes[idx] if idx < len(codes) else None,
                })

            return forecast
        except httpx.HTTPError as e:
            logger.error(f"Error fetching daily forecast: {str(e)}")
            return None
        except Exception as e:
            logger.error(f"Unexpected error in daily forecast: {str(e)}")
            return None

    async def get_district_forecast(self, district: str, days: int = 10) -> Optional[Dict[str, Any]]:
        """
        Fetch forecast for a specific Odisha district using static coordinates.
        """
        if not district:
            return None

        coord = self.district_coords.get(district.strip().lower())
        if not coord:
            logger.warning(f"District {district} not found in coordinate mapping")
            return None

        latitude, longitude = coord
        forecast = await self.get_daily_forecast(latitude, longitude, days)
        if not forecast:
            return None

        return {
            "district": district.title(),
            "latitude": latitude,
            "longitude": longitude,
            "forecast": forecast,
        }

    def _map_weather_code(self, code: Optional[int]) -> str:
        mapping = {
            0: "Clear sky",
            1: "Mainly clear",
            2: "Partly cloudy",
            3: "Overcast",
            45: "Fog",
            48: "Depositing rime fog",
            51: "Light drizzle",
            53: "Moderate drizzle",
            55: "Dense drizzle",
            61: "Slight rain",
            63: "Moderate rain",
            65: "Heavy rain",
            66: "Light freezing rain",
            67: "Heavy freezing rain",
            71: "Slight snow fall",
            73: "Moderate snow fall",
            75: "Heavy snow fall",
            80: "Rain showers",
            81: "Heavy rain showers",
            82: "Violent rain showers",
            95: "Thunderstorm",
            96: "Thunderstorm with hail",
            99: "Severe thunderstorm with hail",
        }
        if code is None:
            return "Unknown"
        return mapping.get(code, "Mixed conditions")

# Singleton instance
weather_service = WeatherService()

