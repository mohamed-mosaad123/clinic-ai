
import sys
import os
import io
import pickle
import pandas as pd
import numpy as np
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, classification_report

# Force UTF-8 output on Windows
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

# ---- Paths ----
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
MODELS_DIR = os.path.join(SCRIPT_DIR, "models")
DATA_DIR   = os.path.join(SCRIPT_DIR, "notebooks")
sys.path.insert(0, SCRIPT_DIR)

def to_binary(v):
    if pd.isna(v): return np.nan
    s = str(v).strip().lower()
    if s in {"0", "no", "negative", "normal", "false", "notckd"}: return 0
    if s in {"1", "yes", "positive", "abnormal", "true", "ckd"}:  return 1
    return 0 if "not" in s else 1

CONFIG = {
    "diabetes": {
        "path": os.path.join(DATA_DIR, "diabetes_prediction_dataset.csv"),
        "target": "diabetes",
        "features": ["HbA1c_level", "blood_glucose_level", "age", "bmi", "smoking_history", "hypertension", "gender", "heart_disease"]
    },
    "heart": {
        "path": os.path.join(DATA_DIR, "heart_2022_no_nans.csv"),
        "target": "HadHeartAttack",
        "features": ["HadAngina", "ChestScan", "HadStroke", "DifficultyWalking", "HadDiabetes", "GeneralHealth", "HadArthritis", "PneumoVaxEver", "RemovedTeeth", "AgeCategory", "SmokerStatus", "BMI", "HadKidneyDisease", "HadCOPD"]
    },
    "kidney": {
        "path": os.path.join(DATA_DIR, "kidney_disease.csv"),
        "target": "classification",
        "features": ["age", "bp", "sg", "al", "su", "rbc", "pc", "pcc", "ba", "bgr", "bu", "sc", "sod", "pot", "hemo", "pcv", "wc", "rc", "htn", "dm", "cad", "appet", "pe", "ane"]
    }
}

def fix_value(x):
    if pd.isna(x): return np.nan
    x = str(x).strip().lower()
    return np.nan if x in ["?", "", "nan", "none", "\t?"] else x

def verify_accuracy():
    print("Healix AI Model Accuracy Verification")
    print("=" * 60)
    print(f"{'Disease':<12} | {'Accuracy':<10} | {'Precision':<10} | {'Recall':<10} | {'F1-Score':<10}")
    print("-" * 60)

    for disease, cfg in CONFIG.items():
        model_path = os.path.join(MODELS_DIR, f"{disease}_model.pkl")
        if not os.path.exists(model_path):
            print(f"{disease:<12} | ERROR: Model not found")
            continue

        try:
            # Load model
            with open(model_path, "rb") as f:
                model = pickle.load(f)

            # Load data
            df = pd.read_csv(cfg["path"])
            
            # Cleaning
            df.columns = [c.strip() for c in df.columns]
            if disease == "kidney":
                for col in df.select_dtypes("object").columns:
                    df[col] = df[col].apply(fix_value)
                df["classification"] = df["classification"].replace("ckd\t", "ckd")
                for col in ["pcv", "wc", "rc"]:
                    df[col] = pd.to_numeric(df[col], errors="coerce")
            
            X = df[cfg["features"]].copy()
            y = df[cfg["target"]].apply(to_binary)
            
            # Filter rows where y is NaN
            valid_idx = y.notna()
            X = X[valid_idx]
            y = y[valid_idx].astype(int)

            y_pred = model.predict(X)
            
            acc = accuracy_score(y, y_pred)
            prec = precision_score(y, y_pred)
            rec = recall_score(y, y_pred)
            f1 = f1_score(y, y_pred)

            print(f"{disease:<12} | {acc*100:>8.2f}% | {prec:>10.3f} | {rec:>10.3f} | {f1:>10.3f}")

        except Exception as e:
            print(f"{disease:<12} | ERROR: {e}")

    print("=" * 60)
    print("✓ Verification Complete.")

if __name__ == "__main__":
    verify_accuracy()
