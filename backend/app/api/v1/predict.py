# backend/app/api/v1/predict.py

from typing import Dict, Any, List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.core.auth import get_current_user
from app.models.models import Farm, Prediction, User
from app.schemas.schemas import (
    PredictIn,
    PredictOut,
    PredictionOut,
    SimplePredictIn,
    SimplePredictOut,
)
from app.i18n import translate
from app.services.dataset_predictor import predict_yield_from_dataset

router = APIRouter()


@router.post("/", response_model=PredictOut)
def predict(
    payload: PredictIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    # 1) Ensure farm belongs to this user
    farm = (
        db.query(Farm)
        .filter(Farm.id == payload.farm_id, Farm.user_id == user.id)
        .first()
    )
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found")

    # 2) Build input features from latest soil sample if present
    latest_soil = farm.soils[-1] if farm.soils else None
    inputs: Dict[str, Any] = {"crop": payload.crop}
    if latest_soil:
        inputs.update(
            {
                "n": latest_soil.n,
                "p": latest_soil.p,
                "k": latest_soil.k,
                "ph": latest_soil.ph,
            }
        )

    # 3) Simple baseline prediction logic (no external predictor file)
    crop = inputs.get("crop", "rice").lower()
    base_yield = {"rice": 3000.0, "wheat": 2500.0, "maize": 2200.0}.get(crop, 2000.0)

    n_val = inputs.get("n")
    if n_val is not None:
        if n_val < 0.2:
            base_yield *= 0.7
        elif n_val < 0.5:
            base_yield *= 0.9

    predicted_yield = round(base_yield, 2)
    confidence = 0.6  # fixed for baseline

    # 4) Structured recommendation (message keys + params)
    # For now, always use the "low nitrogen" style recommendation as example
    raw_recommendation: Dict[str, Any] = {
        "title_key": "rec.low_n_title",
        "title_params": {"kg": 20},
        "summary_key": "rec.low_n_summary",
        "steps": [
            {"step": "rec.step_apply_urea", "params": {"kg_per_ha": 20}},
            {"step": "rec.step_irrigate_if_no_rain", "params": {"days": 7}},
        ],
        "cost_estimate": 150.0,
        "raw_text_en": "Apply 20 kg/ha urea now; irrigate if no rainfall in 7 days.",
    }

    # 5) Localization using user.language_preference
    lang = (user.language_preference or "en").lower()

    title_key = raw_recommendation.get("title_key", "")
    title_params = raw_recommendation.get("title_params", {}) or {}
    summary_key = raw_recommendation.get("summary_key", "")

    title_text = translate(title_key, lang, title_params)
    summary_text = translate(summary_key, lang)

    raw_steps: List[Dict[str, Any]] = raw_recommendation.get("steps", [])
    steps_localized: List[Dict[str, Any]] = []
    for step in raw_steps:
        s_key = step.get("step")
        s_params = step.get("params", {}) or {}
        s_text = translate(s_key, lang, s_params)
        steps_localized.append(
            {
                "step": s_key,
                "params": s_params,
                "text": s_text,
            }
        )

    final_recommendation: Dict[str, Any] = {
        "title_key": title_key,
        "title_text": title_text,
        "title_params": title_params,
        "summary_key": summary_key,
        "summary_text": summary_text,
        "steps": steps_localized,
        "cost_estimate": raw_recommendation.get("cost_estimate"),
        "raw_text_en": raw_recommendation.get("raw_text_en"),
    }

    # 6) Save prediction in DB (including recommendation inside inputs JSON)
    save_inputs = inputs.copy()
    save_inputs["recommendation"] = final_recommendation

    pred = Prediction(
        farm_id=farm.id,
        crop=payload.crop,
        predicted_yield_kg_per_ha=predicted_yield,
        model_version="baseline-v0",
        inputs=save_inputs,
    )
    db.add(pred)
    db.commit()
    db.refresh(pred)

    # 7) Return response matching PredictOut schema
    return PredictOut(
        predicted_yield=predicted_yield,
        confidence=confidence,
        recommendation=final_recommendation,
    )



@router.post("/simple", response_model=SimplePredictOut)
def simple_predict(
    payload: SimplePredictIn,
    user: User = Depends(get_current_user),
):
    """Simple yield prediction based on district, crop, season and land area,
    enriched with irrigation + NPK suggestions using the AIML dataset.
    """
    yield_t_ha, total_tons = predict_yield_from_dataset(
        district=payload.district,
        crop=payload.crop,
        season=payload.season,
        area_acres=payload.area_acres,
    )

    # Dynamic accuracy calculation based on input validation
    accuracy = 0.8  # Base accuracy
    
    # Check for outlier values that might reduce accuracy
    outlier_penalty = 0.0
    if payload.n_kg_per_ha is not None:
        if payload.n_kg_per_ha > 500 or payload.n_kg_per_ha < 0:
            outlier_penalty += 0.3
        elif payload.n_kg_per_ha > 200:
            outlier_penalty += 0.1
    if payload.p_kg_per_ha is not None:
        if payload.p_kg_per_ha > 300 or payload.p_kg_per_ha < 0:
            outlier_penalty += 0.3
        elif payload.p_kg_per_ha > 150:
            outlier_penalty += 0.1
    if payload.k_kg_per_ha is not None:
        if payload.k_kg_per_ha > 300 or payload.k_kg_per_ha < 0:
            outlier_penalty += 0.3
        elif payload.k_kg_per_ha > 150:
            outlier_penalty += 0.1
    if payload.irrigation_days is not None:
        if payload.irrigation_days > 30 or payload.irrigation_days < 0:
            outlier_penalty += 0.2
    
    accuracy = max(0.1, accuracy - outlier_penalty)  # Minimum 10% accuracy

    # Build human-readable recommendations
    recs: List[str] = []
    
    # Add warning if accuracy is low due to outliers
    if accuracy < 0.5:
        recs.append(
            "⚠️ Warning: Some input values seem unusual. Results may be less accurate. Please verify your inputs."
        )

    if payload.irrigation_days is not None:
        if payload.irrigation_days < 4:
            recs.append(
                "Increase irrigation frequency: recorded irrigation days are relatively low."
            )
        elif payload.irrigation_days > 10:
            recs.append(
                "Irrigation days are high; check for waterlogging and adjust schedule."
            )

    def _npk_check(val: float, name: str, low: float, high: float) -> None:
        if val < low:
            recs.append(f"Increase {name}: current value ({val}) is below {low}.")
        elif val > high:
            recs.append(f"Reduce {name}: current value ({val}) is above {high}.")

    if payload.n_kg_per_ha is not None:
        _npk_check(payload.n_kg_per_ha, "Nitrogen (N)", 40, 90)
    if payload.p_kg_per_ha is not None:
        _npk_check(payload.p_kg_per_ha, "Phosphorus (P)", 20, 60)
    if payload.k_kg_per_ha is not None:
        _npk_check(payload.k_kg_per_ha, "Potassium (K)", 20, 80)

    if not recs:
        recs.append(
            "Your current irrigation and NPK values look reasonable. Maintain current practices and monitor weather forecasts."
        )

    return SimplePredictOut(
        predicted_yield_t_ha=yield_t_ha,
        predicted_total_tons=total_tons,
        accuracy=accuracy,
        message="Predicted from historical dataset averages (tons/ha and total tons).",
        recommendations=recs,
    )


@router.get("/farm/{farm_id}", response_model=List[PredictionOut])
def list_predictions_for_farm(
    farm_id: int,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """List all predictions for a specific farm"""
    farm = db.query(Farm).filter(Farm.id == farm_id, Farm.user_id == user.id).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found")
    
    predictions = (
        db.query(Prediction)
        .filter(Prediction.farm_id == farm_id)
        .order_by(Prediction.date_run.desc())
        .all()
    )
    return predictions


@router.get("/{prediction_id}", response_model=PredictionOut)
def get_prediction(
    prediction_id: int,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get a specific prediction by ID"""
    pred = db.query(Prediction).filter(Prediction.id == prediction_id).first()
    if not pred:
        raise HTTPException(status_code=404, detail="Prediction not found")
    
    if pred.farm.user_id != user.id:
        raise HTTPException(status_code=403, detail="Access denied")
    
    return pred
