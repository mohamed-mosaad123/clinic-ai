"""
ModelRegistry – loads and caches every disease model at startup.

The registry is attached to `app.state` so every request gets an O(1)
dict lookup instead of loading from disk on every call.
"""
from __future__ import annotations

import logging
import os
import pickle
import joblib

logger = logging.getLogger("clinicai")

SUPPORTED_DISEASES = ["diabetes", "heart", "kidney"]


class ModelRegistry:
    def __init__(self, models_dir: str):
        self._dir = os.path.abspath(models_dir)
        self._models: dict[str, object] = {}

    # ── Public API ──────────────────────────────────────────────────────────

    def load_all(self) -> list[str]:
        """Load models from disk (.pkl or .joblib). Call once at startup."""
        loaded = []
        for disease in SUPPORTED_DISEASES:
            # Check for .pkl first (user preference), then .joblib
            path_pkl = os.path.join(self._dir, f"{disease}_model.pkl")
            path_joblib = os.path.join(self._dir, f"{disease}_model.joblib")
            
            target_path = path_pkl if os.path.exists(path_pkl) else path_joblib
            
            if not os.path.exists(target_path):
                logger.warning(
                    "Model '%s' not found (tried .pkl and .joblib) at %s",
                    disease, self._dir,
                )
                continue
                
            try:
                if target_path.endswith('.pkl'):
                    with open(target_path, "rb") as f:
                        self._models[disease] = pickle.load(f)
                else:
                    self._models[disease] = joblib.load(target_path)
                loaded.append(disease)
                logger.info("✓  Model loaded: %-10s  ←  %s", disease, target_path)
            except Exception as exc:
                logger.error("Failed to load model '%s': %s", disease, exc)

        return loaded

    def get(self, disease: str) -> object:
        model = self._models.get(disease)
        if model is None:
            raise KeyError(f"Model for disease '{disease}' is not loaded or missing.")
        return model

    @property
    def loaded_models(self) -> list[str]:
        return list(self._models.keys())

    # ── Private ─────────────────────────────────────────────────────────────

    def _model_path(self, disease: str) -> str:
        return os.path.join(self._dir, f"{disease}_model.pkl")
