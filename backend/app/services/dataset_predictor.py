from functools import lru_cache
from pathlib import Path
from typing import Tuple

import pandas as pd


@lru_cache(maxsize=1)
def _load_group_stats():
    """Load the historical dataset and pre-compute mean yield by (district, crop, season)."""

    # dataset_predictor.py is in: backend/app/services/
    services_dir = Path(__file__).resolve().parent          # .../backend/app/services
    backend_root = services_dir.parent.parent               # .../backend

    # CSV is at: backend/app/data/final_dataset.csv
    csv_path = backend_root / "app" / "data" / "final_dataset.csv"

    if not csv_path.exists():
        raise FileNotFoundError(f"Dataset not found at {csv_path}")

    df = pd.read_csv(csv_path)

    # Drop rows without key fields
    df = df.dropna(subset=["District", "Crop", "Season", "Yield_t_ha"])

    # Normalize keys
    df["District_key"] = df["District"].astype(str).str.strip().str.lower()
    df["Crop_key"] = df["Crop"].astype(str).str.strip().str.lower()
    df["Season_key"] = df["Season"].astype(str).str.strip().str.lower()

    group = (
        df.groupby(["District_key", "Crop_key", "Season_key"])["Yield_t_ha"]
        .mean()
    )
    overall_mean = float(df["Yield_t_ha"].mean())
    return group, overall_mean


def _normalize_crop_name(crop: str) -> str:
    """Normalize crop names to handle variations in the dataset."""
    crop_lower = crop.strip().lower()

    if crop_lower in ["horsegram", "horse-gram"]:
        return crop_lower
    elif "moong" in crop_lower:
        if "green-gram" in crop_lower or "green)" in crop_lower:
            return "moong(green-gram)"
        elif "green" in crop_lower:
            return "moong(green)"
    elif "rapeseed" in crop_lower or "mustard" in crop_lower:
        if "mustart" in crop_lower:
            return "rapeseed & mustart"
        else:
            return "rapeseed & mustard"

    return crop_lower


def predict_yield_from_dataset(
    *,
    district: str,
    crop: str,
    season: str,
    area_acres: float,
) -> Tuple[float, float]:
    """Return (yield_t_ha, total_tons) based on historical averages."""

    group, overall_mean = _load_group_stats()

    district_key = district.strip().lower()
    crop_key = _normalize_crop_name(crop)
    season_key = season.strip().lower()

    # Try exact match first
    key = (district_key, crop_key, season_key)
    base_yield = group.get(key, None)

    # If not found, try crop name variations
    if base_yield is None:
        crop_variations = []
        if crop_key in ["horsegram", "horse-gram"]:
            crop_variations = ["horsegram", "horse-gram"]
        elif "moong" in crop_key:
            crop_variations = ["moong(green-gram)", "moong(green)"]
        elif "rapeseed" in crop_key or "mustard" in crop_key:
            crop_variations = ["rapeseed & mustard", "rapeseed & mustart"]

        for alt_crop in crop_variations:
            alt_key = (district_key, alt_crop, season_key)
            base_yield = group.get(alt_key, None)
            if base_yield is not None:
                break

    # Fallback to overall mean
    if base_yield is None:
        base_yield = overall_mean

    base_yield = float(base_yield)

    # Convert acres to hectares (1 acre ≈ 0.404686 ha)
    area_ha = float(area_acres) * 0.404686
    total_tons = base_yield * area_ha

    return base_yield, total_tons
