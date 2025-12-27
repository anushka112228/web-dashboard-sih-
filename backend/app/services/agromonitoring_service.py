"""
Agromonitoring Service - Fetches agricultural monitoring data
"""
import httpx
from typing import Dict, Any, Optional
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)

class AgromonitoringService:
    def __init__(self):
        self.api_key = settings.AGROMONITORING_API_KEY
        self.base_url = "https://api.agromonitoring.com/agro/1.0"
    
    async def get_soil_data(self, latitude: float, longitude: float) -> Optional[Dict[str, Any]]:
        """
        Fetch soil data for given coordinates
        
        Args:
            latitude: Latitude of the location
            longitude: Longitude of the location
            
        Returns:
            Dictionary containing soil data or None if error
        """
        if not self.api_key:
            logger.warning("Agromonitoring API key not configured")
            return None
        
        try:
            # Agromonitoring API endpoint for soil data
            url = f"{self.base_url}/soil"
            params = {
                "lat": latitude,
                "lon": longitude,
                "appid": self.api_key
            }
            
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.get(url, params=params)
                response.raise_for_status()
                data = response.json()
                
                return {
                    "soil_temperature": data.get("t0", {}).get("value"),
                    "soil_moisture": data.get("moisture", {}).get("value"),
                    "raw_data": data
                }
                
        except httpx.HTTPError as e:
            logger.error(f"Error fetching agromonitoring soil data: {str(e)}")
            # Return mock data if API fails (for development)
            return self._get_mock_soil_data()
        except Exception as e:
            logger.error(f"Unexpected error in agromonitoring service: {str(e)}")
            return self._get_mock_soil_data()
    
    async def get_satellite_imagery(self, latitude: float, longitude: float, start_date: str, end_date: str) -> Optional[Dict[str, Any]]:
        """
        Fetch satellite imagery data for given coordinates and date range
        
        Args:
            latitude: Latitude of the location
            longitude: Longitude of the location
            start_date: Start date in YYYY-MM-DD format
            end_date: End date in YYYY-MM-DD format
            
        Returns:
            Dictionary containing satellite imagery data or None if error
        """
        if not self.api_key:
            logger.warning("Agromonitoring API key not configured")
            return None
        
        try:
            # Agromonitoring API endpoint for satellite imagery
            url = f"{self.base_url}/image/search"
            params = {
                "lat": latitude,
                "lon": longitude,
                "start": start_date,
                "end": end_date,
                "appid": self.api_key
            }
            
            async with httpx.AsyncClient(timeout=15.0) as client:
                response = await client.get(url, params=params)
                response.raise_for_status()
                data = response.json()
                
                return {
                    "images": data,
                    "count": len(data) if isinstance(data, list) else 0
                }
                
        except httpx.HTTPError as e:
            logger.error(f"Error fetching satellite imagery: {str(e)}")
            return None
        except Exception as e:
            logger.error(f"Unexpected error in satellite imagery service: {str(e)}")
            return None
    
    async def get_ndvi_data(self, latitude: float, longitude: float) -> Optional[Dict[str, Any]]:
        """
        Fetch NDVI (Normalized Difference Vegetation Index) data
        
        Args:
            latitude: Latitude of the location
            longitude: Longitude of the location
            
        Returns:
            Dictionary containing NDVI data or None if error
        """
        if not self.api_key:
            logger.warning("Agromonitoring API key not configured")
            return None
        
        try:
            # Agromonitoring API endpoint for NDVI
            url = f"{self.base_url}/ndvi"
            params = {
                "lat": latitude,
                "lon": longitude,
                "appid": self.api_key
            }
            
            async with httpx.AsyncClient(timeout=10.0) as client:
                response = await client.get(url, params=params)
                response.raise_for_status()
                data = response.json()
                
                return {
                    "ndvi": data.get("ndvi"),
                    "raw_data": data
                }
                
        except httpx.HTTPError as e:
            logger.error(f"Error fetching NDVI data: {str(e)}")
            return None
        except Exception as e:
            logger.error(f"Unexpected error in NDVI service: {str(e)}")
            return None
    
    def _get_mock_soil_data(self) -> Dict[str, Any]:
        """
        Return mock soil data when API is unavailable (for development)
        """
        return {
            "soil_temperature": 25.5,
            "soil_moisture": 0.45,
            "note": "Mock data - API unavailable"
        }

# Singleton instance
agromonitoring_service = AgromonitoringService()

