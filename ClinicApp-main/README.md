# ClinicApp

A full-stack medical clinic management platform with integrated AI-powered disease prediction. The system enables patients to manage profiles and appointments while providing physicians with an intelligent diagnostic engine capable of analyzing clinical data for cardiovascular disease, chronic kidney disease, and diabetes.

---

## Architecture Overview

The project is composed of three independent services that communicate over HTTP:

```
┌─────────────────┐        ┌─────────────────────┐        ┌──────────────────────┐
│  React Frontend │ ──────▶│  ASP.NET Core API   │ ──────▶│  FastAPI AI Service  │
│   (Port 5174)   │        │     (Port 5001)      │        │     (Port 8000)      │
└─────────────────┘        └─────────────────────┘        └──────────────────────┘
                                      │
                                      ▼
                           ┌─────────────────────┐
                           │   SQL Server 2022   │
                           │    (Port 1433)       │
                           └─────────────────────┘
```

| Layer        | Technology                              | Purpose                                         |
|--------------|-----------------------------------------|-------------------------------------------------|
| Frontend     | React 18, Vite, Tailwind CSS            | Patient/Doctor user interfaces                  |
| Backend API  | ASP.NET Core 8, Entity Framework Core   | Business logic, auth, data persistence          |
| AI Service   | FastAPI, XGBoost, scikit-learn, pandas  | Disease prediction inference engine             |
| Database     | SQL Server 2022 (Docker)                | Relational data storage                         |
| Auth         | JWT Bearer Tokens                       | Stateless authentication                        |

---

## Features

### Patient Portal
- Role-based registration and login (Patient / Doctor)
- Personal health profile with medical history
- Appointment booking with specialist search
- Appointment scheduling and cancellation
- AI-powered disease analysis submission

### Doctor Portal
- Dedicated dashboard for patient management
- Appointment overview and schedule management

### AI Diagnostic Engine
- Three trained XGBoost classification models
- Real-time inference via REST API
- Risk stratification (Low, Moderate, High, Very High)
- Probability scoring with calibrated outputs

| Model    | Accuracy | Precision | Recall | F1-Score |
|----------|----------|-----------|--------|----------|
| Diabetes | 97%      | 0.87      | 0.73   | 0.80     |
| Heart    | 94%      | 0.44      | 0.50   | 0.47     |
| Kidney   | 93%      | 0.92      | 0.93   | 0.92     |

> Note: Heart model recall is lower due to significant class imbalance in the training dataset (232,587 negative vs 13,435 positive cases).

---

## Project Structure

```
ClinicApp-main/
├── Clinic Project/          # ASP.NET Core 8 Backend
│   ├── Controllers/         # API endpoint controllers
│   ├── Services/            # Business logic layer
│   ├── Repositories/        # Data access layer
│   ├── Models/              # Entity models (EF Core)
│   ├── Dtos/                # Data transfer objects
│   ├── Extensions/          # Middleware, seeding, DI setup
│   ├── Helpers/             # JWT, error types, utilities
│   ├── Profiles/            # AutoMapper profiles
│   └── Program.cs           # Application entry point
│
├── ClinicAI/                # FastAPI AI Microservice
│   ├── app/
│   │   ├── main.py          # FastAPI application and lifespan
│   │   ├── routes.py        # Prediction endpoint
│   │   ├── schemas.py       # Pydantic request/response schemas
│   │   ├── preprocessing.py # Inference-time data preparation
│   │   ├── model_registry.py# Singleton model loader
│   │   └── config.py        # Environment settings
│   ├── models/              # Trained .pkl model files
│   ├── notebooks/           # Training notebooks and datasets
│   └── Dockerfile
│
├── frontend/                # React + Vite Frontend
│   ├── src/
│   │   ├── pages/           # Application pages/routes
│   │   ├── services/        # Axios API service layer
│   │   ├── context/         # React context providers
│   │   └── index.css        # Global design system (CSS variables)
│   └── vite.config.js
│
├── Clinic Project.Tests/    # Backend unit tests
├── PostmanCollections/      # API testing collections
├── docker-compose.yml       # Full-stack orchestration
└── README.md
```

---

## Prerequisites

- [Node.js](https://nodejs.org/) v18 or later
- [.NET SDK](https://dotnet.microsoft.com/) 8.0
- [Python](https://www.python.org/) 3.10 or later
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)

---

## Local Development Setup

### Step 1 — Start the Database

```bash
docker compose up sqlserver -d
```

Wait until the health check passes before continuing.

### Step 2 — Start the AI Service

```bash
cd ClinicAI
python -m venv venv
venv\Scripts\activate        # Windows
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

The service will be available at `http://localhost:8000`.  
API documentation: `http://localhost:8000/docs`

### Step 3 — Start the Backend API

```bash
cd "Clinic Project"
dotnet restore
dotnet run
```

The API will be available at `http://localhost:5001`.  
The database schema and seed data are applied automatically on first run via EF Core migrations.

### Step 4 — Start the Frontend

```bash
cd frontend
npm install
npm run dev
```

The application will be available at `http://localhost:5174`.

---

## Docker (Full Stack)

To run the entire stack with a single command:

```bash
docker compose up --build
```

This starts SQL Server, the AI service, and the .NET backend in the correct order with health checks enforced. The frontend is intended for local development only and is not included in the compose file.

---

## Environment Configuration

### Backend — `appsettings.json`

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost,1433;Database=ClinicApp;User Id=sa;Password=Clinic_Secret_Pass_2024!;TrustServerCertificate=True"
  },
  "JWT": {
    "Issuer": "ClinicApp",
    "Audience": "ClinicAppUsers",
    "SecretKey": "YOUR_SECRET_KEY_MINIMUM_32_CHARS"
  },
  "AIService": {
    "BaseUrl": "http://localhost:8000",
    "ApiKey": "clinic_secret_key_2024",
    "TimeoutSeconds": 30,
    "RetryCount": 2
  }
}
```

### AI Service — `.env` (optional)

```env
API_KEY=clinic_secret_key_2024
DEBUG=False
MODELS_DIR=./models
```

---

## API Reference

### Authentication

| Method | Endpoint                    | Description              | Auth Required |
|--------|-----------------------------|--------------------------|---------------|
| POST   | `/api/accounts/register`    | Register a new user      | No            |
| POST   | `/api/accounts/login`       | Login and receive JWT    | No            |
| GET    | `/api/accounts/profile`     | Get current user profile | Yes           |

### Appointments

| Method | Endpoint                            | Description                     | Auth Required |
|--------|-------------------------------------|---------------------------------|---------------|
| GET    | `/api/appointments/patient/{id}`    | Get appointments for a patient  | Yes           |
| POST   | `/api/appointments`                 | Book a new appointment          | Yes           |
| DELETE | `/api/appointments/{id}`            | Cancel an appointment           | Yes           |

### AI Diagnosis

| Method | Endpoint               | Description                        | Auth Required |
|--------|------------------------|------------------------------------|---------------|
| POST   | `/api/diagnosis/predict` | Submit clinical data for analysis | Yes           |

**Prediction Request Body:**

```json
{
  "disease": "diabetes",
  "data": {
    "HbA1c_level": 6.5,
    "blood_glucose_level": 140,
    "age": 45,
    "bmi": 28.3,
    "smoking_history": "never",
    "hypertension": 0,
    "gender": "Male",
    "heart_disease": 0
  }
}
```

**Prediction Response:**

```json
{
  "disease": "diabetes",
  "prediction": 1,
  "probability": 0.7812,
  "risk_level": "high",
  "risk_description": "Multiple risk factors found. Please see a doctor.",
  "label": "Likely Positive",
  "model_version": "1.0.0"
}
```

Supported disease values: `diabetes`, `heart`, `kidney`.

---

## AI Model Input Features

### Diabetes
`HbA1c_level`, `blood_glucose_level`, `age`, `bmi`, `smoking_history`, `hypertension`, `gender`, `heart_disease`

### Heart Disease
`HadAngina`, `ChestScan`, `HadStroke`, `DifficultyWalking`, `HadDiabetes`, `GeneralHealth`, `HadArthritis`, `PneumoVaxEver`, `RemovedTeeth`, `AgeCategory`, `SmokerStatus`, `BMI`, `HadKidneyDisease`, `HadCOPD`

### Chronic Kidney Disease
`age`, `bp`, `sg`, `al`, `su`, `rbc`, `pc`, `pcc`, `ba`, `bgr`, `bu`, `sc`, `sod`, `pot`, `hemo`, `pcv`, `wc`, `rc`, `htn`, `dm`, `cad`, `appet`, `pe`, `ane`

---

## Training the AI Models

If you need to retrain the models from scratch, open and run the notebook:

```
ClinicAI/notebooks/train_clinic_ai.ipynb
```

The notebook loads the CSV datasets, prepares data pipelines (imputation, scaling, ordinal encoding), applies SMOTE for class imbalance on diabetes and heart models, trains XGBoost classifiers with isotonic calibration, and saves the resulting `.pkl` files to `ClinicAI/models/`.

---

## Design System

The frontend uses a CSS variable-based theming system defined in `src/index.css`. All components reference these variables to ensure full light/dark mode compatibility without hardcoded color values.

| Variable      | Light Mode | Dark Mode |
|---------------|------------|-----------|
| `--bg-app`    | `#F8FAFC`  | `#0F172A` |
| `--bg-card`   | `#FFFFFF`  | `#0F172A` |
| `--text-main` | `#1E293B`  | `#F8FAFC` |
| `--text-sub`  | `#64748B`  | `#94A3B8` |
| `--border`    | `#F1F5F9`  | `#1E293B` |
| `--input-bg`  | `#F1F5F9`  | `#1E293B` |

The theme is toggled by adding or removing the `dark` class on the `<html>` element, with the preference persisted in `localStorage`.

---

## Security Notes

- All diagnosis and profile endpoints are protected by JWT Bearer authentication.
- The AI service validates every inbound request against a shared API key via the `x-api-key` header.
- A global Axios response interceptor on the frontend automatically clears the session and redirects to login on any `401 Unauthorized` response.
- The default secret keys in this repository are for local development only. Rotate all keys before any production deployment.

---

## Running Tests

### Backend Unit Tests

```bash
cd "Clinic Project.Tests"
dotnet test
```

### API Integration Tests (Python)

```bash
python test_dotnet.py
```

---

## Known Limitations

- The heart disease model has a 50% recall on positive cases due to the training dataset imbalance. This is a data limitation, not a code defect.
- The `heart_2022_no_nans.csv` training dataset is 78 MB and exceeds GitHub's recommended file size. Consider Git LFS for future dataset management.
- The `AutoMapper` package (v14.0.0) carries a known security advisory (NU1903). An upgrade is recommended before production deployment.
- Appointment cancellation is currently handled locally on the frontend without a backend DELETE call. This is noted for future implementation.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
