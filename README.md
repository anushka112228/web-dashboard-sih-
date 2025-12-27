# Smart Agriculture Management System - Backend API

A comprehensive backend API for managing farms, soil samples, and crop yield predictions with multi-language support and offline sync capabilities.

## Features

- 🔐 **Authentication & Authorization**: JWT-based authentication with refresh tokens
- 🗺️ **Geospatial Farm Management**: Store and manage farm boundaries using GeoJSON polygons
- 🌱 **Soil Sample Tracking**: Record and manage soil test data (pH, N, P, K)
- 📊 **Crop Yield Prediction**: AI-powered yield predictions with actionable recommendations
- 🌍 **Multi-language Support**: English, Hindi, and Odia translations
- 📱 **Offline Sync**: Push/pull mechanism for mobile apps working offline
- 🔄 **Device Management**: Device binding for mobile applications
- 📝 **RESTful API**: Complete CRUD operations for all resources

## Tech Stack

- **Framework**: FastAPI 0.101.1
- **Database**: PostgreSQL with PostGIS extension
- **ORM**: SQLAlchemy 2.0.27
- **Authentication**: JWT (python-jose)
- **Geospatial**: GeoAlchemy2, Shapely
- **Containerization**: Docker & Docker Compose

## Prerequisites

- Python 3.11+
- PostgreSQL 15+ with PostGIS extension
- Docker & Docker Compose (optional, for containerized setup)

## Installation

### Option 1: Docker Compose (Recommended)

1. Clone the repository:
```bash
git clone <repository-url>
cd SIH25044/backend
```

2. Create a `.env` file from the example:
```bash
cp .env.example .env
```

3. Edit `.env` with your configuration:
```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_password
POSTGRES_DB=sih
SECRET_KEY=your-secret-key-here
```

4. Start the services:
```bash
docker-compose up -d
```

The API will be available at `http://localhost:8000`

### Option 2: Local Development

1. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Set up PostgreSQL database with PostGIS:
```sql
CREATE DATABASE sih;
\c sih
CREATE EXTENSION postgis;
```

4. Create `.env` file (see Option 1, step 2-3)

5. Run the application:
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## API Documentation

Once the server is running, access the interactive API documentation:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register a new user
- `POST /api/v1/auth/login` - Login and get access token
- `POST /api/v1/token/refresh` - Refresh access token

### Farms
- `GET /api/v1/farms` - List all farms for the user
- `POST /api/v1/farms` - Create a new farm
- `GET /api/v1/farms/{farm_id}` - Get farm details
- `PUT /api/v1/farms/{farm_id}` - Update farm
- `PATCH /api/v1/farms/{farm_id}` - Partially update farm
- `DELETE /api/v1/farms/{farm_id}` - Delete farm

### Soil Samples
- `GET /api/v1/soil_samples` - List all soil samples (optional: `?farm_id=X`)
- `POST /api/v1/soil_samples` - Create a new soil sample
- `GET /api/v1/soil_samples/farm/{farm_id}` - List samples for a farm
- `GET /api/v1/soil_samples/{sample_id}` - Get sample details
- `PUT /api/v1/soil_samples/{sample_id}` - Update sample
- `PATCH /api/v1/soil_samples/{sample_id}` - Partially update sample
- `DELETE /api/v1/soil_samples/{sample_id}` - Delete sample

### Predictions
- `POST /api/v1/predict` - Get yield prediction for a crop
- `GET /api/v1/predict/farm/{farm_id}` - List predictions for a farm
- `GET /api/v1/predict/{prediction_id}` - Get prediction details

### Device & Sync
- `POST /api/v1/device/bind` - Bind a mobile device
- `POST /api/v1/sync/push` - Push offline data to server
- `GET /api/v1/sync/pull` - Pull data from server

### Onboarding
- `GET /api/v1/onboarding/tips` - Get localized onboarding tips

## Authentication

All endpoints (except `/api/v1/auth/register` and `/api/v1/auth/login`) require authentication.

Include the JWT token in the Authorization header:
```
Authorization: Bearer <your_access_token>
```

## Example Usage

### 1. Register a User
```bash
curl -X POST "http://localhost:8000/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "phone": "+1234567890",
    "password": "securepassword",
    "language_preference": "en"
  }'
```

### 2. Login
```bash
curl -X POST "http://localhost:8000/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+1234567890",
    "password": "securepassword"
  }'
```

### 3. Create a Farm
```bash
curl -X POST "http://localhost:8000/api/v1/farms" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Rice Field",
    "geom": {
      "type": "Polygon",
      "coordinates": [[
        [77.123, 28.456],
        [77.124, 28.456],
        [77.124, 28.457],
        [77.123, 28.457],
        [77.123, 28.456]
      ]]
    }
  }'
```

### 4. Add Soil Sample
```bash
curl -X POST "http://localhost:8000/api/v1/soil_samples" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "farm_id": 1,
    "ph": 6.5,
    "n": 0.3,
    "p": 0.4,
    "k": 0.5
  }'
```

### 5. Get Yield Prediction
```bash
curl -X POST "http://localhost:8000/api/v1/predict" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "farm_id": 1,
    "crop": "rice"
  }'
```

## Database Schema

### Users
- `id`, `name`, `phone`, `hashed_password`, `language_preference`, `created_at`

### Farms
- `id`, `user_id`, `name`, `geom` (PostGIS Polygon), `area_ha`, `created_at`

### Soil Samples
- `id`, `farm_id`, `sample_date`, `ph`, `n`, `p`, `k`, `extra` (JSON)

### Predictions
- `id`, `farm_id`, `crop`, `date_run`, `predicted_yield_kg_per_ha`, `model_version`, `inputs` (JSON)

### Devices
- `id`, `user_id`, `device_uid`, `created_at`

### Refresh Tokens
- `id`, `user_id`, `device_id`, `token`, `created_at`

### Sync Logs
- `id`, `user_id`, `client_id`, `record_type`, `server_id`, `payload` (JSON), `created_at`

## Environment Variables

See `.env.example` for all available configuration options.

## Development

### Running Tests
```bash
# Add tests in tests/ directory
pytest
```

### Code Formatting
```bash
black .
isort .
```

### Database Migrations
Currently using SQLAlchemy's `Base.metadata.create_all()`. For production, consider using Alembic for migrations.

## Production Deployment

1. Set strong `SECRET_KEY` in environment
2. Use secure database credentials
3. Enable HTTPS
4. Configure CORS properly (currently allows all origins)
5. Set up proper logging
6. Use environment-specific configurations
7. Consider using Alembic for database migrations

## Multi-language Support

The API supports three languages:
- `en` - English
- `hi` - Hindi (हिंदी)
- `or` - Odia (ଓଡ଼ିଆ)

Language preference is set during user registration and can be used in recommendations and tips.

## License

[Add your license here]

## Contributing

[Add contribution guidelines here]

## Support

For issues and questions, please open an issue in the repository.

