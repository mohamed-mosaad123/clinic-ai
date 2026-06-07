"""
ClinicAI API Test — Tests all 3 disease endpoints (diabetes, heart, kidney)
"""
import requests
import json

BASE_URL = "http://127.0.0.1:8000"
API_KEY  = "clinic_secret_key_2024"
HEADERS  = {"x-api-key": API_KEY, "Content-Type": "application/json"}

# ── Test Data ────────────────────────────────────────────────────────────

tests = [
    {
        "name": "DIABETES",
        "payload": {
            "disease": "diabetes",
            "data": {
                "HbA1c_level": 6.5,
                "blood_glucose_level": 140,
                "age": 45,
                "bmi": 27.5,
                "smoking_history": "never",
                "hypertension": 0,
                "gender": "Female",
                "heart_disease": 0
            }
        }
    },
    {
        "name": "HEART",
        "payload": {
            "disease": "heart",
            "data": {
                "HadAngina": "No",
                "ChestScan": "No",
                "HadStroke": "No",
                "DifficultyWalking": "No",
                "HadDiabetes": "No",
                "GeneralHealth": "Very good",
                "HadArthritis": "No",
                "PneumoVaxEver": "Yes",
                "RemovedTeeth": "None of them",
                "AgeCategory": "Age 65 to 69",
                "SmokerStatus": "Never smoked",
                "BMI": 27.99,
                "HadKidneyDisease": "No",
                "HadCOPD": "No"
            }
        }
    },
    {
        "name": "KIDNEY",
        "payload": {
            "disease": "kidney",
            "data": {
                "age": 48.0, "bp": 80.0, "sg": 1.020, "al": 1.0,
                "su": 0.0, "rbc": "normal", "pc": "normal",
                "pcc": "notpresent", "ba": "notpresent",
                "bgr": 121.0, "bu": 36.0, "sc": 1.2,
                "sod": 137.0, "pot": 4.0, "hemo": 15.4,
                "pcv": 44.0, "wc": 7800.0, "rc": 5.2,
                "htn": "no", "dm": "no", "cad": "no",
                "appet": "good", "pe": "no", "ane": "no"
            }
        }
    }
]

# ── Run Tests ────────────────────────────────────────────────────────────

print("=" * 60)
print("ClinicAI API Integration Tests")
print("=" * 60)

# Health check first
try:
    r = requests.get(f"{BASE_URL}/api/v1/health", headers=HEADERS)
    print(f"\nHealth Check: {r.status_code}")
    print(json.dumps(r.json(), indent=2))
except Exception as e:
    print(f"\n❌ Health check FAILED: {e}")
    print("Make sure the API server is running!")
    exit(1)

print()

passed = 0
failed = 0

for test in tests:
    print(f"\n{'─'*60}")
    print(f"Testing: {test['name']}")
    print(f"{'─'*60}")
    try:
        r = requests.post(
            f"{BASE_URL}/api/v1/predict",
            headers=HEADERS,
            json=test["payload"]
        )
        if r.status_code == 200:
            data = r.json()
            print(f"  Status:      ✅ {r.status_code} OK")
            print(f"  Prediction:  {data.get('prediction')} ({'DISEASE' if data.get('prediction') == 1 else 'HEALTHY'})")
            print(f"  Probability: {data.get('probability', 0):.4f}")
            print(f"  Risk Level:  {data.get('risk_level')}")
            print(f"  Description: {data.get('risk_description')}")
            passed += 1
        else:
            print(f"  Status: ❌ {r.status_code}")
            print(f"  Error:  {r.text}")
            failed += 1
    except Exception as e:
        print(f"  ❌ EXCEPTION: {e}")
        failed += 1

print(f"\n{'='*60}")
print(f"Results: {passed} PASSED / {failed} FAILED")
print(f"{'='*60}")
