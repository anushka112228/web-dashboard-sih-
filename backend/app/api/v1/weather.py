"""
Weather API endpoints - Retrieve and manage weather data
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional, Tuple
from datetime import datetime, timedelta
from app.db.session import get_db
from app.models.models import Farm, WeatherData, User
from app.core.auth import get_current_user
from app.services.weather_service import weather_service
from app.services.agromonitoring_service import agromonitoring_service
from app.schemas.schemas import WeatherDataOut, DistrictForecastOut
from shapely.geometry import shape
from geoalchemy2.shape import to_shape
import logging

logger = logging.getLogger(__name__)

router = APIRouter()
@router.get("/district-forecast", response_model=DistrictForecastOut)
async def get_district_forecast(
    district: str = Query(..., description="Name of the Odisha district"),
    days: int = Query(default=10, ge=1, le=16),
    user: User = Depends(get_current_user),
):
    """
    Fetch up to 16-day forecast for a given Odisha district (default 10 days).
    """
    data = await weather_service.get_district_forecast(district, days=days)
    if not data:
        raise HTTPException(
            status_code=404,
            detail="Forecast unavailable for this district. Please verify the name.",
        )
    return data



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


@router.post("/fetch/{farm_id}", response_model=WeatherDataOut)
async def fetch_weather_for_farm(
    farm_id: int,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Manually trigger weather data fetch for a specific farm
    """
    farm = db.query(Farm).filter(Farm.id == farm_id, Farm.user_id == user.id).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found")
    
    longitude, latitude = get_farm_center(farm)
    if latitude is None or longitude is None:
        raise HTTPException(status_code=400, detail="Farm geometry not available")
    
    # Fetch current weather
    weather_data = await weather_service.get_current_weather(latitude, longitude)
    if not weather_data:
        raise HTTPException(status_code=503, detail="Weather service unavailable")
    
    # Fetch forecast
    forecast_data = await weather_service.get_forecast(latitude, longitude, days=5)
    
    # Fetch agromonitoring data
    agro_data = await agromonitoring_service.get_soil_data(latitude, longitude)
    
    # Store or update weather data
    existing_weather = db.query(WeatherData).filter(
        WeatherData.farm_id == farm_id
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
        db.commit()
        db.refresh(existing_weather)
        return existing_weather
    else:
        # Create new record
        new_weather = WeatherData(
            farm_id=farm_id,
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
        db.refresh(new_weather)
        return new_weather


@router.get("/farm/{farm_id}", response_model=WeatherDataOut)
def get_weather_for_farm(
    farm_id: int,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get latest weather data for a specific farm
    """
    farm = db.query(Farm).filter(Farm.id == farm_id, Farm.user_id == user.id).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found")
    
    weather = db.query(WeatherData).filter(
        WeatherData.farm_id == farm_id
    ).order_by(WeatherData.recorded_at.desc()).first()
    
    if not weather:
        raise HTTPException(status_code=404, detail="No weather data found for this farm")
    
    return weather


@router.get("/farm/{farm_id}/history", response_model=List[WeatherDataOut])
def get_weather_history(
    farm_id: int,
    days: int = Query(default=7, ge=1, le=30),
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get weather history for a farm
    """
    farm = db.query(Farm).filter(Farm.id == farm_id, Farm.user_id == user.id).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found")
    
    since_date = datetime.utcnow() - timedelta(days=days)
    weather_records = db.query(WeatherData).filter(
        WeatherData.farm_id == farm_id,
        WeatherData.recorded_at >= since_date
    ).order_by(WeatherData.recorded_at.desc()).all()
    
    return weather_records


@router.post("/fetch-all")
async def fetch_weather_for_all_farms(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Manually trigger weather data fetch for all user's farms
    """
    farms = db.query(Farm).filter(Farm.user_id == user.id).all()
    if not farms:
        return {"message": "No farms found", "updated": 0}
    
    updated_count = 0
    for farm in farms:
        try:
            longitude, latitude = get_farm_center(farm)
            if latitude is None or longitude is None:
                continue
            
            # Fetch weather data
            weather_data = await weather_service.get_current_weather(latitude, longitude)
            if not weather_data:
                continue
            
            forecast_data = await weather_service.get_forecast(latitude, longitude, days=5)
            agro_data = await agromonitoring_service.get_soil_data(latitude, longitude)
            
            # Update or create weather record
            existing_weather = db.query(WeatherData).filter(
                WeatherData.farm_id == farm.id
            ).order_by(WeatherData.recorded_at.desc()).first()
            
            if existing_weather:
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
            
            updated_count += 1
        except Exception as e:
            logger.error(f"Error updating weather for farm {farm.id}: {str(e)}")
            continue
    
    db.commit()
    return {"message": f"Updated weather data for {updated_count} farms", "updated": updated_count}

