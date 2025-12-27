"""
Background tasks for automatic weather data retrieval
"""
import asyncio
from datetime import datetime, timedelta
from typing import Tuple, Optional
from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.models.models import Farm, WeatherData, User
from app.services.weather_service import weather_service
from app.services.agromonitoring_service import agromonitoring_service
from app.core.config import settings
from geoalchemy2.shape import to_shape
import logging

logger = logging.getLogger(__name__)


def get_farm_center(farm: Farm) -> Tuple[Optional[float], Optional[float]]:
    """Extract center coordinates from farm geometry"""
    if farm.geom:
        try:
            geom = to_shape(farm.geom)
            centroid = geom.centroid
            return (centroid.x, centroid.y)  # (longitude, latitude)
        except Exception as e:
            logger.error(f"Error extracting farm center: {str(e)}")
    return None, None


async def update_weather_for_farm(farm: Farm, db: Session):
    """Update weather data for a single farm"""
    try:
        longitude, latitude = get_farm_center(farm)
        if latitude is None or longitude is None:
            logger.warning(f"Farm {farm.id} has no valid geometry")
            return False
        
        # Fetch current weather
        weather_data = await weather_service.get_current_weather(latitude, longitude)
        if not weather_data:
            logger.warning(f"Could not fetch weather for farm {farm.id}")
            return False
        
        # Fetch forecast
        forecast_data = await weather_service.get_forecast(latitude, longitude, days=5)
        
        # Fetch agromonitoring data
        agro_data = await agromonitoring_service.get_soil_data(latitude, longitude)
        
        # Update or create weather record
        existing_weather = db.query(WeatherData).filter(
            WeatherData.farm_id == farm.id
        ).order_by(WeatherData.recorded_at.desc()).first()
        
        if existing_weather:
            # Update existing record
            existing_weather.temperature = weather_data.get("temperature")
            existing_weather.humidity = weather_data.get("humidity")
            existing_weather.pressure = weather_data.get("pressure")
            existing_weather.wind_speed = weather_data.get("wind_speed")
            existing_weather.wind_direction = weather_data.get("wind_direction")
            existing_weather.precipitation = weather_data.get("precipitation")
            existing_weather.visibility = weather_data.get("visibility")
            existing_weather.weather_description = weather_data.get("weather_description")
            existing_weather.weather_icon = weather_data.get("weather_icon")
            existing_weather.forecast_data = forecast_data
            existing_weather.agromonitoring_data = agro_data
            existing_weather.updated_at = datetime.utcnow()
        else:
            # Create new record
            new_weather = WeatherData(
                farm_id=farm.id,
                latitude=latitude,
                longitude=longitude,
                temperature=weather_data.get("temperature"),
                humidity=weather_data.get("humidity"),
                pressure=weather_data.get("pressure"),
                wind_speed=weather_data.get("wind_speed"),
                wind_direction=weather_data.get("wind_direction"),
                precipitation=weather_data.get("precipitation"),
                visibility=weather_data.get("visibility"),
                weather_description=weather_data.get("weather_description"),
                weather_icon=weather_data.get("weather_icon"),
                forecast_data=forecast_data,
                agromonitoring_data=agro_data
            )
            db.add(new_weather)
        
        db.commit()
        logger.info(f"Successfully updated weather for farm {farm.id}")
        return True
        
    except Exception as e:
        logger.error(f"Error updating weather for farm {farm.id}: {str(e)}")
        db.rollback()
        return False


async def update_all_weather_data():
    """
    Background task to update weather data for all farms
    This should be called periodically (e.g., every 6 hours)
    """
    db: Session = SessionLocal()
    try:
        logger.info("Starting automatic weather data update...")
        
        # Get all farms with valid geometry
        farms = db.query(Farm).filter(Farm.geom.isnot(None)).all()
        
        if not farms:
            logger.info("No farms found with valid geometry")
            return
        
        updated_count = 0
        failed_count = 0
        
        # Update weather for each farm (with rate limiting)
        for farm in farms:
            success = await update_weather_for_farm(farm, db)
            if success:
                updated_count += 1
            else:
                failed_count += 1
            
            # Small delay to avoid rate limiting
            await asyncio.sleep(0.5)
        
        logger.info(f"Weather update completed: {updated_count} succeeded, {failed_count} failed")
        
    except Exception as e:
        logger.error(f"Error in background weather update task: {str(e)}")
    finally:
        db.close()


def run_weather_update_sync():
    """
    Synchronous wrapper for the async weather update function
    This can be called from a scheduler
    """
    asyncio.run(update_all_weather_data())

