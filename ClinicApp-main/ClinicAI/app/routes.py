"""
API routes — all /api/v1/* endpoints live here.
"""
from __future__ import annotations

import logging

from fastapi import APIRouter, HTTPException, Request, status

from .schemas import (
    HealthResponse,
    PredictionRequest,
    PredictionResponse,
)
from .preprocessing import preprocess, classify_risk

logger = logging.getLogger("clinicai")
router = APIRouter(prefix="/api/v1")


# ── Health ─────────────────────────────────────────────────────────────────

@router.get(
    "/health",
    response_model=HealthResponse,
    summary="Health check",
    tags=["Health"],
)
async def health(request: Request) -> HealthResponse:
    """Returns service status and which models are currently loaded."""
    registry = request.app.state.registry
    settings = request.app.state.settings
    return HealthResponse(
        status="ok",
        version=settings.app_version,
        models_loaded=registry.loaded_models,
    )


# ── Prediction ─────────────────────────────────────────────────────────────

@router.post(
    "/predict",
    response_model=PredictionResponse,
    status_code=status.HTTP_200_OK,
    summary="Disease prediction",
    tags=["Prediction"],
)
async def predict(body: PredictionRequest, request: Request) -> PredictionResponse:
    # NEW: Log raw request body for debugging
    logger.info("Raw request body: %s", body.dict())
    
    disease = body.disease.value
    registry = request.app.state.registry

    # 1 — validate model is available
    try:
        pipeline = registry.get(disease)
    except KeyError as exc:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=str(exc),
        )

    # 2 — preprocess input
    try:
        input_df = preprocess(body.data, disease)
    except Exception as exc:
        logger.warning("Preprocessing failed for %s: %s", disease, exc)
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"Input preprocessing error: {exc}",
        )

    # 3 — run inference
    try:
        prediction      = int(pipeline.predict(input_df)[0])
        probability     = float(pipeline.predict_proba(input_df)[0][1])
        risk_key, risk_desc = classify_risk(probability)
        human_label     = "Likely DISEASED ⚠" if prediction == 1 else "Likely HEALTHY ✓"
    except Exception as exc:
        logger.exception("Inference error for disease=%s", disease)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Inference failed: {exc}",
        )

    logger.info(
        "disease=%-8s  pred=%d  prob=%.4f  risk=%s",
        disease, prediction, probability, risk_key,
    )

    return PredictionResponse(
        disease=body.disease,
        prediction=prediction,
        probability=round(probability, 4),
        risk_level=risk_key,
        risk_description=risk_desc,
        label=human_label,
    )
