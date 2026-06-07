import pickle
import numpy as np

model_path = "models/heart_disease_model.pkl"
with open(model_path, "rb") as f:
    pipeline = pickle.load(f)

print(pipeline)

# The pipeline might be a scikit-learn Pipeline or CalibratedClassifierCV
# Let's inspect its structure.
try:
    if hasattr(pipeline, "estimator"):
        # CalibratedClassifierCV
        base_estimator = pipeline.estimator
        # Or if it's calibrated, we might need to look at calibrated_classifiers_
        if hasattr(pipeline, "calibrated_classifiers_"):
            xgb_model = pipeline.calibrated_classifiers_[0].estimator
        else:
            xgb_model = base_estimator.named_steps["classifier"] if hasattr(base_estimator, "named_steps") else base_estimator
    elif hasattr(pipeline, "named_steps"):
        xgb_model = pipeline.named_steps["classifier"]
    else:
        xgb_model = pipeline

    if hasattr(xgb_model, "feature_importances_"):
        importances = xgb_model.feature_importances_
        # Try to get feature names
        if hasattr(pipeline, "named_steps") and "preprocessor" in pipeline.named_steps:
            preprocessor = pipeline.named_steps["preprocessor"]
            feature_names = preprocessor.get_feature_names_out()
        else:
            feature_names = [f"f{i}" for i in range(len(importances))]
        
        print("Feature Importances:")
        for name, imp in sorted(zip(feature_names, importances), key=lambda x: x[1], reverse=True):
            print(f"{name}: {imp:.4f}")
except Exception as e:
    print("Error getting feature importances:", e)
