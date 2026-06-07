"""
test_presets.py - Healix AI Preset Verifier (Final Calibration)
==============================================================
"""

import sys
import os
import io
import pickle

# Force UTF-8 output on Windows
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

import numpy as np
import pandas as pd

# ---- Paths ----------------------------------------------------------------
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
MODELS_DIR = os.path.join(SCRIPT_DIR, "models")
sys.path.insert(0, SCRIPT_DIR)

from app.preprocessing import preprocess

# ---- Helpers --------------------------------------------------------------
def tier_label(prob):
    if prob < 0.30:  return "HEALTHY   "
    if prob < 0.60:  return "AT RISK   "
    return               "UNHEALTHY "

def ok_fail(expected, prob):
    bands = {
        "healthy":   (0.00, 0.30),
        "risk":      (0.30, 0.60),
        "unhealthy": (0.60, 1.01),
    }
    lo, hi = bands[expected]
    return "PASS" if lo <= prob < hi else "FAIL"

# ---- Updated Presets (Matching ai_agent_page.dart) ------------------------
PRESETS = {
    "diabetes": {
        "healthy": {
            "HbA1c_level": 4.5, "blood_glucose_level": 82.0, "age": 25.0,
            "bmi": 21.0, "smoking_history": "never", "hypertension": 0,
            "gender": "Female", "heart_disease": 0,
        },
        "risk": {
            "HbA1c_level": 5.8, "blood_glucose_level": 120.0, "age": 40.0,
            "bmi": 27.5, "smoking_history": "never", "hypertension": 0,
            "gender": "Male", "heart_disease": 0,
        },
        "unhealthy": {
            "HbA1c_level": 9.5, "blood_glucose_level": 240.0, "age": 58.0,
            "bmi": 36.0, "smoking_history": "current", "hypertension": 1,
            "gender": "Male", "heart_disease": 1,
        },
    },
    "kidney": {
        "healthy": {
            "age": 32.0, "bp": 68.0, "sg": 1.022, "al": 0.0, "su": 0.0,
            "rbc": "normal", "pc": "normal", "pcc": "notpresent", "ba": "notpresent",
            "bgr": 88.0, "bu": 18.0, "sc": 0.8, "sod": 141.0, "pot": 4.1,
            "hemo": 15.5, "pcv": 45.0, "wc": 7200.0, "rc": 5.3,
            "htn": "no", "dm": "no", "cad": "no", "appet": "good", "pe": "no", "ane": "no",
        },
        "risk": {
            "age": 45.0, "bp": 80.0, "sg": 1.015, "al": 1.0, "su": 0.0,
            "rbc": "normal", "pc": "normal", "pcc": "notpresent", "ba": "notpresent",
            "bgr": 110.0, "bu": 30.0, "sc": 1.4, "sod": 135.0, "pot": 4.5,
            "hemo": 13.0, "pcv": 38.0, "wc": 8000.0, "rc": 4.5,
            "htn": "no", "dm": "no", "cad": "no", "appet": "good", "pe": "no", "ane": "no",
        },
        "unhealthy": {
            "age": 70.0, "bp": 120.0, "sg": 1.005, "al": 5.0, "su": 5.0,
            "rbc": "abnormal", "pc": "abnormal", "pcc": "present", "ba": "present",
            "bgr": 480.0, "bu": 150.0, "sc": 15.0, "sod": 108.0, "pot": 7.0,
            "hemo": 6.0, "pcv": 20.0, "wc": 14000.0, "rc": 2.3,
            "htn": "yes", "dm": "yes", "cad": "yes", "appet": "poor", "pe": "yes", "ane": "yes",
        },
    },
    "heart": {
        "healthy": {
            "HadAngina": "No", "ChestScan": "No", "HadStroke": "No",
            "DifficultyWalking": "No", "HadDiabetes": "No", "GeneralHealth": "Excellent",
            "HadArthritis": "No", "PneumoVaxEver": "No", "RemovedTeeth": "None of them",
            "AgeCategory": "Age 25 to 29", "SmokerStatus": "Never smoked",
            "BMI": 21.5, "HadKidneyDisease": "No", "HadCOPD": "No",
            "State": "California", "Sex": "Male", "PhysicalHealthDays": 0,
            "MentalHealthDays": 0, "LastCheckupTime": "Within past year",
            "PhysicalActivities": "Yes", "SleepHours": 8, "HadAsthma": "No",
            "HadSkinCancer": "No", "HadDepressiveDisorder": "No",
            "DeafOrHardOfHearing": "No", "BlindOrVisionDifficulty": "No",
            "DifficultyConcentrating": "No", "DifficultyDressingBathing": "No",
            "DifficultyErrands": "No", "ECigaretteUsage": "Not at all",
            "RaceEthnicityCategory": "White only, Non-Hispanic",
            "HeightInMeters": 1.75, "WeightInKilograms": 65.0,
            "AlcoholDrinkers": "No", "HIVTesting": "No", "FluVaxLast12": "No",
            "TetanusLast10Tdap": "No, did not receive any tetanus shot in the past 10 years",
            "HighRiskLastYear": "No", "CovidPos": "No",
        },
        "risk": {
            "HadAngina": "Yes", "ChestScan": "Yes", "HadStroke": "No",
            "DifficultyWalking": "No", "HadDiabetes": "Yes", "GeneralHealth": "Fair",
            "HadArthritis": "Yes", "PneumoVaxEver": "No", "RemovedTeeth": "1 to 5",
            "AgeCategory": "Age 65 to 69", "SmokerStatus": "Former smoker",
            "BMI": 32.0, "HadKidneyDisease": "No", "HadCOPD": "No",
            "State": "California", "Sex": "Male", "PhysicalHealthDays": 10,
            "MentalHealthDays": 5, "LastCheckupTime": "Within past year",
            "PhysicalActivities": "No", "SleepHours": 6, "HadAsthma": "No",
            "HadSkinCancer": "No", "HadDepressiveDisorder": "Yes",
            "DeafOrHardOfHearing": "No", "BlindOrVisionDifficulty": "No",
            "DifficultyConcentrating": "No", "DifficultyDressingBathing": "No",
            "DifficultyErrands": "No", "ECigaretteUsage": "Not at all",
            "RaceEthnicityCategory": "White only, Non-Hispanic",
            "HeightInMeters": 1.75, "WeightInKilograms": 92.0,
            "AlcoholDrinkers": "No", "HIVTesting": "No", "FluVaxLast12": "Yes",
            "TetanusLast10Tdap": "No, did not receive any tetanus shot in the past 10 years",
            "HighRiskLastYear": "No", "CovidPos": "No",
        },
        "unhealthy": {
            "HadAngina": "Yes", "ChestScan": "Yes", "HadStroke": "Yes",
            "DifficultyWalking": "Yes", "HadDiabetes": "Yes", "GeneralHealth": "Poor",
            "HadArthritis": "Yes", "PneumoVaxEver": "Yes", "RemovedTeeth": "All",
            "AgeCategory": "Age 80 or older",
            "SmokerStatus": "Current smoker - now smokes every day",
            "BMI": 38.0, "HadKidneyDisease": "Yes", "HadCOPD": "Yes",
            "State": "California", "Sex": "Male", "PhysicalHealthDays": 28,
            "MentalHealthDays": 20, "LastCheckupTime": "Within past year",
            "PhysicalActivities": "No", "SleepHours": 4, "HadAsthma": "Yes",
            "HadSkinCancer": "Yes", "HadDepressiveDisorder": "Yes",
            "DeafOrHardOfHearing": "Yes", "BlindOrVisionDifficulty": "Yes",
            "DifficultyConcentrating": "Yes", "DifficultyDressingBathing": "Yes",
            "DifficultyErrands": "Yes", "ECigaretteUsage": "Not at all",
            "RaceEthnicityCategory": "White only, Non-Hispanic",
            "HeightInMeters": 1.70, "WeightInKilograms": 110.0,
            "AlcoholDrinkers": "No", "HIVTesting": "No", "FluVaxLast12": "Yes",
            "TetanusLast10Tdap": "No, did not receive any tetanus shot in the past 10 years",
            "HighRiskLastYear": "Yes", "CovidPos": "Yes",
        },
    },
}

def run_tests():
    all_pass = True
    for disease in ["diabetes", "kidney", "heart"]:
        print(f"\n>> {disease.upper()}")
        try:
            with open(os.path.join(MODELS_DIR, f"{disease}_model.pkl"), "rb") as f:
                model = pickle.load(f)
            for tier in ["healthy", "risk", "unhealthy"]:
                df = preprocess(PRESETS[disease][tier], disease)
                prob = float(model.predict_proba(df)[0][1])
                res = ok_fail(tier, prob)
                print(f"  {tier:<10}: {prob*100:>7.2f}% [{res}]")
                if res == "FAIL": all_pass = False
        except Exception as e:
            print(f"  ERROR: {e}")
            all_pass = False
    
    if all_pass:
        print("\n✅ ALL PRESETS ARE NOW PERFECTLY CALIBRATED!")
    else:
        print("\n❌ CALIBRATION FAILED - CHECK OUTPUT.")

if __name__ == "__main__":
    run_tests()
