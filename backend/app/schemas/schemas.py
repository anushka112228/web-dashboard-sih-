from pydantic import BaseModel, ConfigDict, Field
from typing import Optional, List, Dict, Any
from datetime import datetime

# --- Auth ---
class UserCreate(BaseModel):
    name: str
    phone: str
    password: str
    language_preference: Optional[str] = "en"


class LoginRequest(BaseModel):
    phone: str
    password: str


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"

class UserOut(BaseModel):
    id: int
    name: str
    phone: str
    language_preference: Optional[str]

    model_config = ConfigDict(from_attributes=True)

# --- Farm ---
class FarmCreate(BaseModel):
    name: Optional[str] = None
    # Expect GeoJSON Polygon as dict
    geom: dict

class FarmUpdate(BaseModel):
    name: Optional[str] = None
    geom: Optional[dict] = None

class FarmOut(BaseModel):
    id: int
    name: Optional[str]
    area_ha: Optional[float]
    geom: dict

    model_config = ConfigDict(from_attributes=True)

# --- Soil Sample ---
class SoilSampleIn(BaseModel):
    farm_id: int
    ph: Optional[float] = None
    n: Optional[float] = None
    p: Optional[float] = None
    k: Optional[float] = None
    extra: Optional[Dict] = None

class SoilSampleUpdate(BaseModel):
    ph: Optional[float] = None
    n: Optional[float] = None
    p: Optional[float] = None
    k: Optional[float] = None
    extra: Optional[Dict] = None

class SoilSampleOut(BaseModel):
    id: int
    farm_id: int
    sample_date: datetime
    ph: Optional[float]
    n: Optional[float]
    p: Optional[float]
    k: Optional[float]
    extra: Optional[Dict]

    model_config = ConfigDict(from_attributes=True)

# --- Recommendation ---
class RecommendationStep(BaseModel):
    step: str  # message_key
    params: Optional[Dict[str, Any]] = None
    text: Optional[str] = None # Localized text for frontend

class RecommendationOut(BaseModel):
    title_key: str
    title_params: Optional[Dict[str, Any]] = None
    title_text: Optional[str] = None
    
    summary_key: str
    summary_text: Optional[str] = None
    
    steps: List[RecommendationStep]
    cost_estimate: Optional[float] = None
    raw_text_en: Optional[str] = None

# --- Prediction ---
class PredictIn(BaseModel):
    farm_id: int
    crop: str


class PredictOut(BaseModel):
    predicted_yield: float
    confidence: float
    recommendation: Optional[RecommendationOut] = None


class SimplePredictIn(BaseModel):
    district: str
    crop: str
    season: str
    area_acres: float
    irrigation_days: Optional[int] = None
    n_kg_per_ha: Optional[float] = None
    p_kg_per_ha: Optional[float] = None
    k_kg_per_ha: Optional[float] = None


class SimplePredictOut(BaseModel):
    predicted_yield_t_ha: float
    predicted_total_tons: float
    accuracy: float
    message: Optional[str] = None
    recommendations: List[str] = []

class PredictionOut(BaseModel):
    id: int
    farm_id: int
    crop: str
    date_run: datetime
    predicted_yield_kg_per_ha: Optional[float]
    
    # Fix for "model_" namespace warning in Pydantic v2
    model_version: Optional[str] = Field(default=None, alias="model_version") 
    
    inputs: Optional[Dict[str, Any]]

    model_config = ConfigDict(from_attributes=True, protected_namespaces=())

# --- Device / Sync ---
class DeviceBindOut(BaseModel):
    access_token: str
    token_type: str = "bearer"
    refresh_token: str

class ClientRecord(BaseModel):
    client_id: str
    record_type: str
    payload: Dict[str, Any]

class PushIn(BaseModel):
    records: List[ClientRecord]

class PushOutItem(BaseModel):
    client_id: str
    record_type: str
    server_id: Optional[int]

class PushOut(BaseModel):
    results: List[PushOutItem]

# --- Weather Data ---
class WeatherDataOut(BaseModel):
    id: int
    farm_id: Optional[int]
    latitude: float
    longitude: float
    temperature: Optional[float]
    humidity: Optional[float]
    pressure: Optional[float]
    wind_speed: Optional[float]
    wind_direction: Optional[float]
    precipitation: Optional[float]
    uv_index: Optional[float]
    visibility: Optional[float]
    weather_description: Optional[str]
    weather_icon: Optional[str]
    forecast_data: Optional[Dict[str, Any]]
    agromonitoring_data: Optional[Dict[str, Any]]
    recorded_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)

class WeatherDataCreate(BaseModel):
    farm_id: Optional[int] = None
    latitude: float
    longitude: float


class DailyForecastOut(BaseModel):
    date: str
    condition: str
    temp_min_c: float
    temp_max_c: float
    precipitation_mm: float
    weather_code: int


class DistrictForecastOut(BaseModel):
    district: str
    latitude: float
    longitude: float
    forecast: List[DailyForecastOut]