import pandas as pd
import numpy as np
import os
import pickle

from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OrdinalEncoder, StandardScaler
from sklearn.impute import SimpleImputer
from sklearn.metrics import classification_report

from xgboost import XGBClassifier
from imblearn.over_sampling import SMOTE
from imblearn.pipeline import Pipeline as ImbPipeline

BASE_DIR       = r"notebooks"
MODEL_SAVE_DIR = r"models"

heart_config = {
    "path": os.path.join(BASE_DIR, "heart_2022_no_nans.csv"),
    "target": "HadHeartAttack",
    "features": [
        "HadAngina", "ChestScan", "HadStroke", "DifficultyWalking",
        "HadDiabetes", "GeneralHealth", "HadArthritis", "PneumoVaxEver",
        "RemovedTeeth", "AgeCategory", "SmokerStatus", "BMI",
        "HadKidneyDisease", "HadCOPD"
    ]
}

def to_binary(v):
    if pd.isna(v):
        return np.nan
    if isinstance(v, (int, float, np.integer, np.floating)):
        return 1 if float(v) != 0 else 0
    s = str(v).strip().lower()
    if s in {"0", "no", "negative", "normal", "false", "notckd"}: return 0
    if s in {"1", "yes", "positive", "abnormal", "true", "ckd"}:  return 1
    return 0 if "not" in s else 1

def build_preprocessor(X):
    cat_cols = X.select_dtypes(include=["object", "category", "bool"]).columns.tolist()
    num_cols = [c for c in X.columns if c not in cat_cols]

    num_pipe = Pipeline([
        ("imputer", SimpleImputer(strategy="median")),
        ("scaler",  StandardScaler())
    ])

    cat_pipe = Pipeline([
        ("imputer", SimpleImputer(strategy="most_frequent")),
        ("encoder", OrdinalEncoder(
            handle_unknown="use_encoded_value",
            unknown_value=-1
        ))
    ])

    return ColumnTransformer([
        ("num", num_pipe, num_cols),
        ("cat", cat_pipe, cat_cols)
    ])

def make_xgb_balanced():
    # Remove CalibratedClassifierCV to allow SMOTE/scale_pos_weight to inflate probabilities.
    # Set scale_pos_weight=3 to give more weight to positive class, or rely on SMOTE.
    # We will use scale_pos_weight=3 and no SMOTE for a purely cost-sensitive approach, 
    # or keep SMOTE and just remove CalibratedClassifierCV.
    # Let's use scale_pos_weight=10 and no SMOTE to be faster, or keep SMOTE.
    # Actually, the user asked to give more balanced importance. We'll use scale_pos_weight=5.
    return XGBClassifier(
        n_estimators=300,
        learning_rate=0.05,
        max_depth=5,            # slightly deeper to catch interactions without Angina
        min_child_weight=10,
        subsample=0.8,
        colsample_bytree=0.7,
        scale_pos_weight=8,     # Increase recall
        eval_metric="logloss",
        tree_method="hist",
        random_state=42
    )

def main():
    print("Loading heart data...")
    df = pd.read_csv(heart_config["path"])
    df.columns = [c.strip() for c in df.columns]
    
    feature_cols = heart_config["features"]
    target_col = heart_config["target"]
    
    df = df[feature_cols + [target_col]].copy()
    X = df[feature_cols].copy()
    y = df[target_col].apply(to_binary)
    
    X = X[y.notna()]
    y = y[y.notna()].astype(int)
    
    preprocessor = build_preprocessor(X)
    
    # We drop SMOTE for speed and rely on scale_pos_weight, which is effectively equivalent for XGBoost
    model = Pipeline([
        ("preprocessor", preprocessor),
        ("classifier", make_xgb_balanced())
    ])
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    
    print("Training model...")
    model.fit(X_train, y_train)
    
    y_pred = model.predict(X_test)
    print("\nHEART — Test Results")
    print(classification_report(y_test, y_pred))
    
    # Check feature importance
    xgb_model = model.named_steps["classifier"]
    importances = xgb_model.feature_importances_
    
    # Extract feature names from preprocessor
    num_cols = model.named_steps["preprocessor"].transformers_[0][2]
    cat_cols = model.named_steps["preprocessor"].transformers_[1][2]
    feature_names = num_cols + cat_cols
    
    print("\nFeature Importances:")
    for name, imp in sorted(zip(feature_names, importances), key=lambda x: x[1], reverse=True):
        print(f"{name}: {imp:.4f}")
        
    save_path = os.path.join(MODEL_SAVE_DIR, "heart_model.pkl")
    with open(save_path, "wb") as f:
        pickle.dump(model, f)
    print(f"\n✓ Heart model saved to {save_path}")

if __name__ == '__main__':
    main()
