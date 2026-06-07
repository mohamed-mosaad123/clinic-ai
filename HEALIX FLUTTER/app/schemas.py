"""
All Pydantic schemas for the FastAPI layer.

Nothing ML-specific lives here — pure request/response contracts.
"""
from __future__ import annotations

from enum import Enum
from typing import Any, Optional
from pydantic import BaseModel, Field, model_validator

# ── Feature Definitions ──────────────────────────────────────────────────

REQUIRED_FEATURES = {
    "diabetes": {"HbA1c_level", "blood_glucose_level", "age", "bmi", "smoking_history", "hypertension", "gender", "heart_disease"},
    "kidney": {"age", "bp", "sg", "al", "su", "rbc", "pc", "pcc", "ba", "bgr", "bu", "sc", "sod", "pot", "hemo", "pcv", "wc", "rc", "htn", "dm", "cad", "appet", "pe", "ane"},
    "heart": {"State", "Sex", "GeneralHealth", "PhysicalHealthDays", "MentalHealthDays", "LastCheckupTime", "PhysicalActivities", "SleepHours", "RemovedTeeth", "HadAngina", "HadStroke", "HadAsthma", "HadSkinCancer", "HadCOPD", "HadDepressiveDisorder", "HadKidneyDisease", "HadArthritis", "HadDiabetes", "DeafOrHardOfHearing", "BlindOrVisionDifficulty", "DifficultyConcentrating", "DifficultyWalking", "DifficultyDressingBathing", "DifficultyErrands", "SmokerStatus", "ECigaretteUsage", "ChestScan", "RaceEthnicityCategory", "AgeCategory", "HeightInMeters", "WeightInKilograms", "BMI", "AlcoholDrinkers", "HIVTesting", "FluVaxLast12", "PneumoVaxEver", "TetanusLast10Tdap", "HighRiskLastYear", "CovidPos"}
}

# ── Enums ─────────────────────────────────────────────────────────────────

class DiseaseType(str, Enum):
    diabetes = "diabetes"
    heart    = "heart"
    kidney   = "kidney"

class RiskLevel(str, Enum):
    low       = "low"
    moderate  = "moderate"
    high      = "high"
    very_high = "very_high"

# ── Prediction request ─────────────────────────────────────────────────────

class PredictionRequest(BaseModel):
    disease: DiseaseType = Field(..., description="Which disease to predict")
    data: dict[str, Any] = Field(
        ...,
        description="Patient feature key-value pairs. Keys depend on disease type.",
    )

    @model_validator(mode="after")
    def validate_features(self) -> "PredictionRequest":
        disease_name = self.disease.value
        provided_keys = set(self.data.keys())
        required_keys = REQUIRED_FEATURES.get(disease_name, set())
        
        missing = required_keys - provided_keys
        if missing:
            raise ValueError(f"Missing required data fields for {disease_name}: {sorted(missing)}")
            
        # Security/Validation: Prevent illogical parameters like negative age
        if "age" in self.data:
            try:
                age_val = float(self.data["age"])
                if age_val < 0 or age_val > 120:
                    raise ValueError(f"Invalid 'age' provided: {age_val}. Must be 0-120.")
            except (ValueError, TypeError):
                pass # let it pass to preprocessing if it's text
                
        return self

    model_config = {
        "json_schema_extra": {
            "examples": [
                {
                    "summary": "Diabetes example",
                    "value": {
                        "disease": "diabetes",
                        "data": {
                            "HbA1c_level": 6.5,
                            "blood_glucose_level": 140,
                            "age": 45,
                            "bmi": 27.5,
                            "smoking_history": "never",
                            "hypertension": 0,
                            "gender": "Female",
                            "heart_disease": 0,
                        },
                    },
                },
                {
                    "summary": "Kidney example",
                    "value": {
                        "disease": "kidney",
                        "data": {
                            "age": 48.0, "bp": 80.0, "sg": 1.020, "al": 1.0,
                            "su": 0.0, "rbc": "normal", "pc": "normal",
                            "pcc": "notpresent", "ba": "notpresent",
                            "bgr": 121.0, "bu": 36.0, "sc": 1.2,
                            "sod": 137.0, "pot": 4.0, "hemo": 15.4,
                            "pcv": 44.0, "wc": 7800.0, "rc": 5.2,
                            "htn": "no", "dm": "no", "cad": "no",
                            "appet": "good", "pe": "no", "ane": "no",
                        },
                    },
                },
                {
                    "summary": "Heart example (14 features)",
                    "value": {
                        "disease": "heart",
                        "data": {
                            "HadAngina": "No",
                            "ChestScan": "No",
                            "HadStroke": "No",
                            "DifficultyWalking": "No",
                            "HadDiabetes": "No",
                            "GeneralHealth": "Very good",
                            "HadArthritis": "No",
                            "PneumoVaxEver": "Yes",
                            "RemovedTeeth": "None of them",
                            "AgeCategory": "Age 65 to 69",
                            "SmokerStatus": "Never smoked",
                            "BMI": 27.99,
                            "HadKidneyDisease": "No",
                            "HadCOPD": "No"
                        },
                    },
                },
            ]
        }
    }


# ── Prediction response ────────────────────────────────────────────────────

class PredictionResponse(BaseModel):
    disease:          DiseaseType
    prediction:       int   = Field(..., description="0 = healthy, 1 = disease likely")
    probability:      float = Field(..., ge=0.0, le=1.0)
    risk_level:       RiskLevel
    risk_description: str
    label:            str   = Field(..., description="Human-readable result")
    model_version:    str   = "1.0.0"


# ── Health ─────────────────────────────────────────────────────────────────

class HealthResponse(BaseModel):
    status:        str
    version:       str
    models_loaded: list[str]
