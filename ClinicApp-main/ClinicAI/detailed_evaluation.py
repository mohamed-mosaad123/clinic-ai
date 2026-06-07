
import sys
import os
import io
import pickle
import pandas as pd
import numpy as np
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score, 
    confusion_matrix, roc_auc_score, classification_report
)

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

def fix_value(x):
    if pd.isna(x): return np.nan
    x = str(x).strip().lower()
    return np.nan if x in ["?", "", "nan", "none", "\t?"] else x

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

def run_evaluation():
    print("Healix AI: Detailed Model Evaluation")
    print("=" * 60)

    for disease, cfg in CONFIG.items():
        print(f"\n>> {disease.upper()}")
        model_path = os.path.join(MODELS_DIR, f"{disease}_model.pkl")
        if not os.path.exists(model_path):
            print(f"   ERROR: Model not found")
            continue

        try:
            with open(model_path, "rb") as f:
                model = pickle.load(f)

            df = pd.read_csv(cfg["path"])
            df.columns = [c.strip() for c in df.columns]
            
            if disease == "kidney":
                for col in df.select_dtypes("object").columns:
                    df[col] = df[col].apply(fix_value)
                df["classification"] = df["classification"].replace("ckd\t", "ckd")
                for col in ["pcv", "wc", "rc"]:
                    df[col] = pd.to_numeric(df[col], errors="coerce")
            
            X = df[cfg["features"]].copy()
            y = df[cfg["target"]].apply(to_binary)
            
            valid_idx = y.notna()
            X = X[valid_idx]
            y = y[valid_idx].astype(int)

            # Predictions
            y_pred = model.predict(X)
            y_prob = model.predict_proba(X)[:, 1]

            # Metrics
            acc = accuracy_score(y, y_pred)
            prec = precision_score(y, y_pred)
            rec = recall_score(y, y_pred)
            f1 = f1_score(y, y_pred)
            auc = roc_auc_score(y, y_prob)
            cm = confusion_matrix(y, y_pred)

            print(f"   Accuracy      : {acc*100:.2f}%")
            print(f"   Precision     : {prec:.4f}")
            print(f"   Recall        : {rec:.4f}")
            print(f"   F1-Score      : {f1:.4f}")
            print(f"   AUC-ROC       : {auc:.4f}")
            print(f"   Confusion Matrix:")
            print(f"      TN: {cm[0][0]:<8} FP: {cm[0][1]}")
            print(f"      FN: {cm[1][0]:<8} TP: {cm[1][1]}")

        except Exception as e:
            print(f"   ERROR: {e}")

    print("\n" + "=" * 60)
    print("✓ Evaluation Complete.")

if __name__ == "__main__":
    run_evaluation()
