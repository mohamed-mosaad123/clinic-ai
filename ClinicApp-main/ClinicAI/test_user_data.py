
import sys
import os
import io
import pickle
import pandas as pd
import numpy as np

# Force UTF-8 output on Windows
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

# ---- Paths ----
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
MODELS_DIR = os.path.join(SCRIPT_DIR, "models")
sys.path.insert(0, SCRIPT_DIR)

from app.preprocessing import preprocess

USER_DATA = {
    "kidney": {
        "healthy": {
            "age": 35, "bp": 70, "sg": 1.020, "al": 0, "su": 0, "rbc": "normal", "pc": "normal",
            "pcc": "notpresent", "ba": "notpresent", "bgr": 90, "bu": 20, "sc": 0.9, "sod": 140,
            "pot": 4.0, "hemo": 15.0, "pcv": 44, "wc": 7500, "rc": 5.2, "htn": "no", "dm": "no",
            "cad": "no", "appet": "good", "pe": "no", "ane": "no"
        },
        "borderline": {
            "age": 55, "bp": 90, "sg": 1.010, "al": 2, "su": 2, "rbc": "abnormal", "pc": "abnormal",
            "pcc": "present", "ba": "notpresent", "bgr": 140, "bu": 40, "sc": 2.5, "sod": 130,
            "pot": 5.0, "hemo": 11.0, "pcv": 33, "wc": 9000, "rc": 3.8, "htn": "yes", "dm": "yes",
            "cad": "no", "appet": "poor", "pe": "yes", "ane": "no"
        },
        "sick": {
            "age": 68, "bp": 110, "sg": 1.005, "al": 5, "su": 4, "rbc": "abnormal", "pc": "abnormal",
            "pcc": "present", "ba": "present", "bgr": 400, "bu": 100, "sc": 10.0, "sod": 111,
            "pot": 6.0, "hemo": 7.0, "pcv": 24, "wc": 12000, "rc": 2.8, "htn": "yes", "dm": "yes",
            "cad": "yes", "appet": "poor", "pe": "yes", "ane": "yes"
        }
    },
    "heart": {
        "low risk": {
            "HadAngina": "No", "ChestScan": "No", "HadStroke": "No", "DifficultyWalking": "No",
            "HadDiabetes": "No", "GeneralHealth": "Excellent", "HadArthritis": "No",
            "PneumoVaxEver": "No", "RemovedTeeth": "None of them", "AgeCategory": "Age 25 to 29",
            "SmokerStatus": "Never smoked", "BMI": 22.5, "HadKidneyDisease": "No", "HadCOPD": "No"
        },
        "risk": {
            "HadAngina": "No", "ChestScan": "Yes", "HadStroke": "No", "DifficultyWalking": "Yes",
            "HadDiabetes": "Yes", "GeneralHealth": "Fair", "HadArthritis": "Yes",
            "PneumoVaxEver": "Yes", "RemovedTeeth": "1 to 5", "AgeCategory": "Age 55 to 59",
            "SmokerStatus": "Former smoker", "BMI": 29.5, "HadKidneyDisease": "No", "HadCOPD": "No"
        },
        "high risk": {
            "HadAngina": "Yes", "ChestScan": "Yes", "HadStroke": "Yes", "DifficultyWalking": "Yes",
            "HadDiabetes": "Yes", "GeneralHealth": "Poor", "HadArthritis": "Yes",
            "PneumoVaxEver": "Yes", "RemovedTeeth": "All", "AgeCategory": "Age 75 to 79",
            "SmokerStatus": "Current smoker - now smokes every day", "BMI": 35.0,
            "HadKidneyDisease": "Yes", "HadCOPD": "Yes"
        }
    },
    "diabetes": {
        "low": {
            "HbA1c_level": 4.8, "blood_glucose_level": 90, "age": 28, "bmi": 22.5,
            "smoking_history": "never", "hypertension": 0, "gender": "Female", "heart_disease": 0
        },
        "risk": {
            "HbA1c_level": 6.4, "blood_glucose_level": 158, "age": 50, "bmi": 30.1,
            "smoking_history": "current", "hypertension": 1, "gender": "Male", "heart_disease": 0
        },
        "high": {
            "HbA1c_level": 7.5, "blood_glucose_level": 180, "age": 52, "bmi": 32.4,
            "smoking_history": "former", "hypertension": 1, "gender": "Male", "heart_disease": 0
        }
    }
}

def classify_label(prob):
    if prob < 0.20: return "Healthy (Low Risk)"
    if prob < 0.50: return "Borderline (Moderate Risk)"
    return "Sick (High Risk)"

def run_user_tests():
    print("Healix AI Model Testing with User Data")
    print("=" * 50)
    
    for disease, scenarios in USER_DATA.items():
        print(f"\n>> DISEASE: {disease.upper()}")
        model_path = os.path.join(MODELS_DIR, f"{disease}_model.pkl")
        
        if not os.path.exists(model_path):
            print(f"   ERROR: Model file not found at {model_path}")
            continue
            
        try:
            with open(model_path, "rb") as f:
                model = pickle.load(f)
            
            for label, data in scenarios.items():
                # For heart, we might need to fill other features with something to avoid NaN issues if the model can't handle them
                # But let's see what preprocess does first.
                df = preprocess(data, disease)
                
                # Check for NaNs in heart and fill with some neutral value if needed, 
                # though usually the pipeline should have an imputer.
                
                prob = float(model.predict_proba(df)[0][1])
                pred_label = classify_label(prob)
                
                print(f"   {label:<12}: Probability {prob*100:>7.2f}% -> {pred_label}")
                
        except Exception as e:
            print(f"   ERROR testing {disease}: {e}")

if __name__ == "__main__":
    run_user_tests()
