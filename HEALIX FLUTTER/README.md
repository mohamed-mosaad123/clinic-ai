# HEALIX FLUTTER

Quick start instructions for the HEALIX Flutter project and related services included in this folder.

Prerequisites
- Flutter SDK (stable)
- Android SDK (for Android builds)
- Xcode (for iOS builds, macOS only)
- .NET SDK (for `Clinic Project` backend)
- Python 3.8+ (for `ClinicAI` service)

Setup
1. Copy the example env file and fill values:

   - Copy `HEALIX FLUTTER/.env.example` to `HEALIX FLUTTER/.env` and set values.
   - If present, update `android/local.properties` with your Android SDK path (this file is machine-specific).

Flutter app
1. Open a terminal in `HEALIX FLUTTER`.
2. Get packages:

```
flutter pub get
```

3. Run on a connected device or emulator:

```
flutter run
```

Clinic Project (.NET backend)
1. Navigate to `HEALIX FLUTTER/ClinicApp-main/Clinic Project`.
2. Restore and run:

```
dotnet restore
dotnet run
```

ClinicAI (Python service)
1. Navigate to `HEALIX FLUTTER/ClinicApp-main/ClinicAI`.
2. Create and activate a virtual environment, then install requirements:

Windows:
```
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
python app/main.py
```

Linux/macOS:
```
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python app/main.py
```

Notes
- This repository currently contains machine-specific files (for example `.env`, `android/local.properties`, and generated Flutter/iOS artifacts). If you encounter build issues, regenerate those files on your machine.
- Several large data/model files are included in the repo; cloning may be slow.

If you want me to sanitize/remove sensitive files or migrate large files to Git LFS, ask and I will do it.
\# 🤖 Clinic AI Module



\## 📌 Overview

AI system for analyzing clinic data and predictions.



\---



\## ⚙️ Features

\- Data Analysis

\- Machine Learning Models

\- Prediction System



\---



\## 🛠 Tech Stack

\- Python

\- Jupyter Notebook

\- Scikit-learn

\- Pandas



\---



\## ▶️ Run

```bash

pip install -r requirements.txt

python main.py

