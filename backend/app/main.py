from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import asyncio
import logging

# Import routers
from app.api.v1 import auth, farms, predict, device, token, sync, soil_samples, onboarding, weather
from app.core.background_tasks import update_all_weather_data
from app.core.config import settings

logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Lifespan context manager for startup and shutdown events
    """
    # Startup: Start background task for automatic weather updates
    logger.info("Starting background weather update task...")
    
    async def periodic_weather_update():
        """Periodically update weather data"""
        while True:
            try:
                await update_all_weather_data()
                # Wait for the configured interval (convert hours to seconds)
                await asyncio.sleep(settings.WEATHER_UPDATE_INTERVAL_HOURS * 3600)
            except Exception as e:
                logger.error(f"Error in periodic weather update: {str(e)}")
                # Wait 1 hour before retrying on error
                await asyncio.sleep(3600)
    
    # Start the background task
    task = asyncio.create_task(periodic_weather_update())
    
    # Also run an initial update
    asyncio.create_task(update_all_weather_data())
    
    yield
    
    # Shutdown: Cancel the background task
    logger.info("Shutting down background weather update task...")
    task.cancel()
    try:
        await task
    except asyncio.CancelledError:
        pass


# 1. Initialize the App FIRST
app = FastAPI(
    title="SIH Crop Backend - MVP",
    version="0.1",
    lifespan=lifespan
)

# 2. Add CORS Middleware (AFTER initializing app)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 3. Include Routers
app.include_router(auth.router, prefix="/api/v1/auth", tags=["auth"])
app.include_router(farms.router, prefix="/api/v1/farms", tags=["farms"])
app.include_router(device.router, prefix="/api/v1/device", tags=["device"])
app.include_router(token.router, prefix="/api/v1/token", tags=["token"])
app.include_router(sync.router, prefix="/api/v1/sync", tags=["sync"])
app.include_router(soil_samples.router, prefix="/api/v1/soil_samples", tags=["soil_samples"])
app.include_router(onboarding.router, prefix="/api/v1/onboarding", tags=["onboarding"])
app.include_router(weather.router, prefix="/api/v1/weather", tags=["weather"])
app.include_router(predict.router, prefix="/api/v1/predict", tags=["predict"])

@app.get("/health")
def health_check():
    return {"status": "ok"}
