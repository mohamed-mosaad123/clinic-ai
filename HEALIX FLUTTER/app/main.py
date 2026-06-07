"""
FastAPI application entry point.

Startup:  loads all disease models once → attaches them to app.state
Shutdown: clean teardown (nothing heavy needed here)

Run locally:
    uvicorn main:app --reload --port 8000

Via Docker:
    docker compose up clinicai
"""
from __future__ import annotations

import logging
import sys
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import get_settings
from .model_registry import ModelRegistry
from .routes import router
from fastapi import Header, HTTPException, status, Depends

# ── Logging ────────────────────────────────────────────────────────────────

logging.basicConfig(
    stream=sys.stdout,
    level=logging.INFO,
    format="%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%S",
)
logger = logging.getLogger("clinicai")

# ── Settings ───────────────────────────────────────────────────────────────

settings = get_settings()
if settings.debug:
    logging.getLogger().setLevel(logging.DEBUG)

# ── Lifespan ───────────────────────────────────────────────────────────────

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("=== ClinicAI starting up ===")

    app.state.settings = settings

    registry = ModelRegistry(models_dir=settings.models_dir)
    loaded   = registry.load_all()
    app.state.registry = registry

    if not loaded:
        logger.warning(
            "No models loaded! Train them first via the ClinicApp-Ai notebook "
            "and save the .pkl files to the models/ directory."
        )
    else:
        logger.info("Ready — models: %s", loaded)

    logger.info("=== Startup complete ===")
    yield
    logger.info("=== ClinicAI shutting down ===")

# ── App factory ────────────────────────────────────────────────────────────

app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    description=(
        "Internal AI micro-service for ClinicApp.  \n"
        "Exposes disease prediction (diabetes · heart · kidney) trained with XGBoost.  \n"
        "Called exclusively by the .NET backend — not exposed publicly."
    ),
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

async def verify_api_key(x_api_key: str = Header(...)):
    """Simple API Key validation for security."""
    if x_api_key != settings.api_key:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing API Key",
        )

app.include_router(router, dependencies=[Depends(verify_api_key)])
