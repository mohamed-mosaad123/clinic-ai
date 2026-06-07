import requests
import json

def test_heart_prediction():
    # Use the port where the server is CURRENTLY running
    url = "http://127.0.0.1:8000/api/v1/predict"
    
    # Headers with required API Key
    headers = {
        "x-api-key": "clinic_secret_key_2024",
        "Content-Type": "application/json"
    }
    
    # EXACT field names as defined in preprocessing.py and heart_2022_no_nans.csv
    payload = {
        "disease": "heart",
        "data": {
            "State": "Alabama",
            "Sex": "Female",
            "GeneralHealth": "Very good",
            "PhysicalHealthDays": 4.0,
            "MentalHealthDays": 0.0,
            "LastCheckupTime": "Within past year (anytime less than 12 months ago)",
            "PhysicalActivities": "Yes",
            "SleepHours": 9.0,
            "RemovedTeeth": "None of them",
            "HadAngina": "No",
            "HadStroke": "No",
            "HadAsthma": "No",
            "HadSkinCancer": "No",
            "HadCOPD": "No",
            "HadDepressiveDisorder": "No",
            "HadKidneyDisease": "No",
            "HadArthritis": "No",
            "HadDiabetes": "No",
            "DeafOrHardOfHearing": "No",
            "BlindOrVisionDifficulty": "No",
            "DifficultyConcentrating": "No",
            "DifficultyWalking": "No",
            "DifficultyDressingBathing": "No",
            "DifficultyErrands": "No",
            "SmokerStatus": "Never smoked",
            "ECigaretteUsage": "No",
            "ChestScan": "No",
            "RaceEthnicityCategory": "White",
            "AgeCategory": "Age 65 to 69",
            "HeightInMeters": 1.6,
            "WeightInKilograms": 71.67,
            "BMI": 27.99,
            "AlcoholDrinkers": "No",
            "HIVTesting": "No",
            "FluVaxLast12": "Yes",
            "PneumoVaxEver": "Yes",
            "TetanusLast10Tdap": "Yes, received Tdap",
            "HighRiskLastYear": "No",
            "CovidPos": "No"
        }
    }

    print(f"Testing Prediction on: {url} with API Key...")
    try:
        response = requests.post(url, json=payload, headers=headers, timeout=10)
        if response.status_code == 200:
            print("\n✅ API RESPONSE SUCCESS!")
            print(json.dumps(response.json(), indent=4))
        else:
            print(f"\n❌ FAILED (Status {response.status_code})")
            print(f"Error Detail: {response.text}")
            
    except Exception as e:
        print(f"\n📡 CONNECTION ERROR: {e}")

if __name__ == "__main__":
    test_heart_prediction()
