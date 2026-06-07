"""
Preprocessing helpers for inference time.

These mirror the data-cleaning logic from the ClinicApp-Ai notebook
so that API inputs are in exactly the same shape the trained pipeline expects.
"""
from __future__ import annotations

import numpy as np
import pandas as pd

# Feature lists per disease (must match what the models were trained on)
DISEASE_FEATURES: dict[str, list[str]] = {
    "diabetes": [
        "HbA1c_level", "blood_glucose_level", "age", "bmi",
        "smoking_history", "hypertension", "gender", "heart_disease",
    ],
    "heart": [
        "State", "Sex", "GeneralHealth", "PhysicalHealthDays", "MentalHealthDays",
        "LastCheckupTime", "PhysicalActivities", "SleepHours", "RemovedTeeth",
        "HadAngina", "HadStroke", "HadAsthma", "HadSkinCancer", "HadCOPD",
        "HadDepressiveDisorder", "HadKidneyDisease", "HadArthritis", "HadDiabetes",
        "DeafOrHardOfHearing", "BlindOrVisionDifficulty", "DifficultyConcentrating",
        "DifficultyWalking", "DifficultyDressingBathing", "DifficultyErrands",
        "SmokerStatus", "ECigaretteUsage", "ChestScan", "RaceEthnicityCategory",
        "AgeCategory", "HeightInMeters", "WeightInKilograms", "BMI",
        "AlcoholDrinkers", "HIVTesting", "FluVaxLast12", "PneumoVaxEver",
        "TetanusLast10Tdap", "HighRiskLastYear", "CovidPos"
    ],
    "kidney": [
        "age", "bp", "sg", "al", "su",
        "rbc", "pc", "pcc", "ba",
        "bgr", "bu", "sc", "sod", "pot",
        "hemo", "pcv", "wc", "rc",
        "htn", "dm", "cad", "appet", "pe", "ane",
    ],
}


def _fix_value(x):
    """Normalise dirty kidney-dataset string values."""
    if pd.isna(x):
        return np.nan
    x = str(x).strip().lower()
    return np.nan if x in ["?", "", "nan", "none"] else x


def preprocess(raw: dict, disease: str) -> pd.DataFrame:
    """
    Convert a raw API-request dict into a single-row DataFrame
    ready for `pipeline.predict()`.
    """
    features = DISEASE_FEATURES[disease]

    # Build row with only the expected columns (missing → None → NaN)
    row = {feat: raw.get(feat) for feat in features}
    df = pd.DataFrame([row])

    if disease == "diabetes":
        df["smoking_history"] = df["smoking_history"].replace("No Info", np.nan)

    if disease == "kidney":
        for col in df.select_dtypes("object").columns:
            df[col] = df[col].apply(_fix_value)
        
        # Ensure ALL kidney features that should be numeric are actually numeric
        numeric_cols = ["age", "bp", "sg", "al", "su", "bgr", "bu", "sc", "sod", "pot", "hemo", "pcv", "wc", "rc"]
        for col in numeric_cols:
            if col in df.columns:
                df[col] = pd.to_numeric(df[col], errors="coerce")

    return df


def classify_risk(prob: float) -> tuple[str, str]:
    """Map probability → (risk_level_key, human-readable description).

    Bands are reverted to the legacy 20/50/80 calibration:
      low       → prob < 0.20   (HEALTHY)
      moderate  → prob 0.20–0.50 (AT RISK)
      high      → prob 0.50–0.80 (UNHEALTHY)
      very_high → prob ≥ 0.80   (UNHEALTHY – critical)
    """
    if prob < 0.20:
        return "low",      "No significant disease indicators detected."
    if prob < 0.50:
        return "moderate", "Some risk factors present. Consider seeing a doctor."
    if prob < 0.80:
        return "high",     "Multiple risk factors found. Please see a doctor soon."
    return   "very_high",  "Strong disease indicators detected. Please see a doctor immediately."
