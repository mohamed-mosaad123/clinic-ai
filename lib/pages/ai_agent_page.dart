import 'package:flutter/material.dart';
import '../widgets/healix_app_bar.dart';
import '../store/healix_store.dart';
import '../services/ai_service.dart';
import '../services/patient_service.dart';

class AiAgentPage extends StatefulWidget {
  const AiAgentPage({super.key});

  @override
  State<AiAgentPage> createState() => _AiAgentPageState();
}

class _AiAgentPageState extends State<AiAgentPage> {
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  Color get bgColor => isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  Color get cardColor => isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get textColor => isDark ? Colors.white : const Color(0xFF0F172A);
  Color get subTextColor => isDark ? Colors.grey.shade400 : const Color(0xFF64748B);
  Color get borderColor => isDark ? Colors.white10 : const Color(0xFFE2E8F0);
  
  int _currentStep = 0;
  String _selectedDisease = 'Diabetes';
  Map<String, dynamic>? _analysisResult;

  // Input state
  final Map<String, dynamic> _inputs = {};

  // Lazy-init controllers — safe for hot-reload (no initState needed)
  Map<String, TextEditingController>? _controllersMap;
  Map<String, TextEditingController> get _controllers =>
      _controllersMap ??= {};

  TextEditingController _getController(String key) {
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: _inputs[key]?.toString() ?? ''),
    );
  }

  @override
  void dispose() {
    _controllersMap?.forEach((_, c) => c.dispose());
    super.dispose();
  }
  
  double _riskScore = 0.0;
  // 'healthy' | 'risk' | 'unhealthy'
  String _statusLevel = 'healthy';
  String _riskDescription = '';

  // Defaults for each disease to satisfy FastAPI's strict validation
  static const Map<String, dynamic> _diabetesDefaults = {
    "HbA1c_level": 5.7, "blood_glucose_level": 100, "age": 45, "bmi": 25.0,
    "smoking_history": "never", "hypertension": 0, "gender": "Male", "heart_disease": 0
  };

  static const Map<String, dynamic> _kidneyDefaults = {
    "age": 48.0, "bp": 80.0, "sg": 1.020, "al": 0.0, "su": 0.0,
    "rbc": "normal", "pc": "normal", "pcc": "notpresent", "ba": "notpresent",
    "bgr": 121.0, "bu": 36.0, "sc": 1.2, "sod": 137.0, "pot": 4.0, "hemo": 15.4,
    "pcv": 44.0, "wc": 7800.0, "rc": 5.2, "htn": "no", "dm": "no", "cad": "no",
    "appet": "good", "pe": "no", "ane": "no"
  };

  static const Map<String, dynamic> _heartDefaults = {
    "State": "California", "Sex": "Male", "GeneralHealth": "Good", "PhysicalHealthDays": 0, "MentalHealthDays": 0,
    "LastCheckupTime": "Within past year", "PhysicalActivities": "Yes", "SleepHours": 7, "RemovedTeeth": "None of them",
    "HadAngina": "No", "HadStroke": "No", "HadAsthma": "No", "HadSkinCancer": "No", "HadCOPD": "No",
    "HadDepressiveDisorder": "No", "HadKidneyDisease": "No", "HadArthritis": "No", "HadDiabetes": "No",
    "DeafOrHardOfHearing": "No", "BlindOrVisionDifficulty": "No", "DifficultyConcentrating": "No",
    "DifficultyWalking": "No", "DifficultyDressingBathing": "No", "DifficultyErrands": "No",
    "SmokerStatus": "Never smoked", "ECigaretteUsage": "Not at all", "ChestScan": "No",
    "RaceEthnicityCategory": "White only, Non-Hispanic", "AgeCategory": "Age 40 to 44",
    "HeightInMeters": 1.75, "WeightInKilograms": 75.0, "BMI": 24.5, "AlcoholDrinkers": "No",
    "HIVTesting": "No", "FluVaxLast12": "No", "PneumoVaxEver": "No", "TetanusLast10Tdap": "Yes, received Tdap",
    "HighRiskLastYear": "No", "CovidPos": "No"
  };

  final Map<String, Map<String, String>> _modelMetrics = {
    'Diabetes': {'Accuracy': '92.4%', 'Precision': '91.2%', 'Recall': '89.5%', 'F1-Score': '90.3%'},
    'Heart Disease': {'Accuracy': '94.1%', 'Precision': '93.5%', 'Recall': '92.8%', 'F1-Score': '93.1%'},
    'Kidney Disease': {'Accuracy': '98.2%', 'Precision': '97.9%', 'Recall': '98.5%', 'F1-Score': '98.2%'},
  };

  // ── Calibrated presets — tuned so each tier reliably hits its probability band
  // Healthy < 30% prob  |  At Risk 30–60%  |  Unhealthy > 60%
  static const Map<String, Map<String, Map<String, dynamic>>> _presets = {
    'Diabetes': {
      // Target: prob < 30%  (clearly non-diabetic markers)
      'healthy': {
        'HbA1c_level': 4.5, 'blood_glucose_level': 82.0, 'age': 25.0,
        'bmi': 21.0, 'smoking_history': 'never', 'hypertension': 0,
        'gender': 'Female', 'heart_disease': 0,
      },
      // Target: prob 30–60% (borderline pre-diabetic)
      'risk': {
        'HbA1c_level': 6.2, 'blood_glucose_level': 130.0, 'age': 45.0,
        'bmi': 28.0, 'smoking_history': 'never', 'hypertension': 0,
        'gender': 'Male', 'heart_disease': 0,
      },
      // Target: prob > 60% (clearly diabetic)
      'unhealthy': {
        'HbA1c_level': 9.5, 'blood_glucose_level': 240.0, 'age': 58.0,
        'bmi': 36.0, 'smoking_history': 'current', 'hypertension': 1,
        'gender': 'Male', 'heart_disease': 1,
      },
    },
    'Kidney Disease': {
      // Target: prob < 30% (healthy markers)
      'healthy': {
        'age': 32.0, 'bp': 68.0, 'sg': 1.022, 'al': '0', 'su': '0',
        'rbc': 'normal', 'pc': 'normal', 'pcc': 'notpresent', 'ba': 'notpresent',
        'bgr': 88.0, 'bu': 18.0, 'sc': 0.8, 'sod': 141.0, 'pot': 4.1,
        'hemo': 15.5, 'pcv': 45.0, 'wc': 7200.0, 'rc': 5.3,
        'htn': 'no', 'dm': 'no', 'cad': 'no', 'appet': 'good', 'pe': 'no', 'ane': 'no',
      },
      // Target: prob 30–60% (borderline indicators)
      'risk': {
        'age': 60.0, 'bp': 85.0, 'sg': 1.020, 'al': '0', 'su': '0',
        'rbc': 'normal', 'pc': 'normal', 'pcc': 'notpresent', 'ba': 'notpresent',
        'bgr': 120.0, 'bu': 35.0, 'sc': 1.1, 'sod': 137.0, 'pot': 4.3,
        'hemo': 14.0, 'pcv': 41.0, 'wc': 8200.0, 'rc': 4.9,
        'htn': 'no', 'dm': 'no', 'cad': 'no', 'appet': 'good', 'pe': 'no', 'ane': 'no',
      },
      // Target: prob > 60% (severe CKD)
      'unhealthy': {
        'age': 70.0, 'bp': 120.0, 'sg': 1.005, 'al': '5', 'su': '5',
        'rbc': 'abnormal', 'pc': 'abnormal', 'pcc': 'present', 'ba': 'present',
        'bgr': 480.0, 'bu': 150.0, 'sc': 15.0, 'sod': 108.0, 'pot': 7.0,
        'hemo': 6.0, 'pcv': 20.0, 'wc': 14000.0, 'rc': 2.3,
        'htn': 'yes', 'dm': 'yes', 'cad': 'yes', 'appet': 'poor', 'pe': 'yes', 'ane': 'yes',
      },
    },
    'Heart Disease': {
      // Target: prob < 30% (healthy)
      'healthy': {
        'HadAngina': 'No', 'ChestScan': 'No', 'HadStroke': 'No',
        'DifficultyWalking': 'No', 'HadDiabetes': 'No', 'GeneralHealth': 'Excellent',
        'HadArthritis': 'No', 'PneumoVaxEver': 'No', 'RemovedTeeth': 'None of them',
        'AgeCategory': 'Age 25 to 29', 'SmokerStatus': 'Never smoked',
        'BMI': 21.5, 'HadKidneyDisease': 'No', 'HadCOPD': 'No',
      },
      // Target: prob 30–60% (significant risk factors)
      'risk': {
        'HadAngina': 'Yes', 'ChestScan': 'Yes', 'HadStroke': 'No',
        'DifficultyWalking': 'No', 'HadDiabetes': 'Yes', 'GeneralHealth': 'Fair',
        'HadArthritis': 'Yes', 'PneumoVaxEver': 'No', 'RemovedTeeth': '1 to 5',
        'AgeCategory': 'Age 65 to 69', 'SmokerStatus': 'Former smoker',
        'BMI': 32.0, 'HadKidneyDisease': 'No', 'HadCOPD': 'No',
      },
      // Target: prob > 60%  (angina + stroke + all major comorbidities)
      'unhealthy': {
        'HadAngina': 'Yes', 'ChestScan': 'Yes', 'HadStroke': 'Yes',
        'DifficultyWalking': 'Yes', 'HadDiabetes': 'Yes', 'GeneralHealth': 'Poor',
        'HadArthritis': 'Yes', 'PneumoVaxEver': 'Yes', 'RemovedTeeth': 'All',
        'AgeCategory': 'Age 80 or older',
        'SmokerStatus': 'Current smoker - now smokes every day',
        'BMI': 38.0, 'HadKidneyDisease': 'Yes', 'HadCOPD': 'Yes',
      },
    },
  };

  bool _isAnalyzing = false;

  void _onDiseaseSelect(String disease) {
    // Dispose & clear old controllers when disease changes
    _controllersMap?.forEach((_, c) => c.dispose());
    _controllersMap = {};
    setState(() {
      _selectedDisease = disease;
      _currentStep = 1;
      _inputs.clear();
    });
  }

  /// Fill all form fields from a preset (Healthy / At Risk / Unhealthy)
  void _applyPreset(String level) {
    final preset = _presets[_selectedDisease]?[level];
    if (preset == null) return;
    // Reset controllers
    _controllersMap?.forEach((_, c) => c.dispose());
    _controllersMap = {};
    setState(() {
      _inputs
        ..clear()
        ..addAll(preset);
    });
    // Sync text controllers for numeric fields
    for (final entry in preset.entries) {
      if (entry.value is num) {
        final v = entry.value as num;
        _getController(entry.key).text =
            v == v.truncate() ? v.toInt().toString() : v.toString();
      }
    }
  }

  Future<void> _analyzeResults() async {
    setState(() => _isAnalyzing = true);
    
    try {
      // Map disease name to backend expected type
      String diseaseType = _selectedDisease.toLowerCase().replaceAll(' ', '_');
      if (diseaseType == 'diabetes') diseaseType = 'diabetes';
      if (diseaseType == 'heart_disease') diseaseType = 'heart';
      if (diseaseType == 'kidney_disease') diseaseType = 'kidney';

      // Merge user inputs with defaults
      Map<String, dynamic> finalPayload = {};
      if (diseaseType == 'diabetes') finalPayload = {..._diabetesDefaults, ..._inputs};
      if (diseaseType == 'kidney') finalPayload = {..._kidneyDefaults, ..._inputs};
      if (diseaseType == 'heart') finalPayload = {..._heartDefaults, ..._inputs};

      final result = await aiService.predict(
        diseaseType: diseaseType,
        features: finalPayload,
      );

      if (result != null) {
        setState(() {
          _analysisResult = result;
          final prediction = (result['prediction'] as num?)?.toInt() ?? 0;
          final prob = ((result['probability'] as num?) ?? 0.0).toDouble();
          _riskScore = prob * 100;
          _riskDescription = result['risk_description'] ?? '';

          // Probability-based 3-tier classification:
          // Healthy    → prob < 30%   (low disease probability)
          // At Risk    → prob 30–60%  (moderate / borderline zone)
          // Unhealthy  → prob > 60%   (high disease probability)
          //
          // NOTE: We use probability alone (not prediction label) so the
          // thresholds stay consistent across all three disease models.
          if (prob < 0.30) {
            _statusLevel = 'healthy';
          } else if (prob >= 0.60) {
            _statusLevel = 'unhealthy';
          } else {
            _statusLevel = 'risk'; // 30–60% borderline zone
          }
          _currentStep = 2;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('AI service error. Please try again.'), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  String _getRiskLabel(double score) {
    if (score < 30) return 'Low Risk';
    if (score < 60) return 'Moderate Risk';
    if (score < 85) return 'High Risk';
    return 'Critical Risk';
  }

  Color _getRiskColor(double score) {
    if (score < 30) return Colors.green;
    if (score < 60) return Colors.orange;
    if (score < 85) return Colors.redAccent;
    return Colors.red;
  }

  // ── 3-state helpers ──────────────────────────────────────────────────────
  Color get _statusColor {
    if (_statusLevel == 'healthy') return const Color(0xFF22C55E);
    if (_statusLevel == 'risk')    return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  IconData get _statusIcon {
    if (_statusLevel == 'healthy') return Icons.check_circle_rounded;
    if (_statusLevel == 'risk')    return Icons.warning_amber_rounded;
    return Icons.dangerous_rounded;
  }

  String get _statusTitle {
    if (_statusLevel == 'healthy') return 'HEALTHY';
    if (_statusLevel == 'risk')    return 'AT RISK';
    return 'UNHEALTHY';
  }

  String get _statusSubtitle {
    if (_statusLevel == 'healthy') return "You're in good health! Keep it up.";
    if (_statusLevel == 'risk')    return 'Some risk factors detected. Monitor closely.';
    return 'Disease indicators found. Please consult a doctor.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: HealixAppBar(
        extraActions: _currentStep > 0 ? [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor),
            onPressed: () => setState(() => _currentStep = 0),
          )
        ] : null,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildSelectionStep();
      case 1: return _buildInputStep();
      case 2: return _buildResultStep();
      default: return _buildSelectionStep();
    }
  }

  Widget _buildSelectionStep() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Disease Prediction',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a specialized AI model to begin your analysis.',
          style: TextStyle(color: subTextColor, fontSize: 16),
        ),
        const SizedBox(height: 32),
        _selectionCard('Diabetes', Icons.water_drop_outlined, 'Analyze glucose and metabolic factors.'),
        _selectionCard('Heart Disease', Icons.favorite_outline, 'Predict cardiac health based on vitals.'),
        _selectionCard('Kidney Disease', Icons.opacity_outlined, 'Evaluate renal function and markers.'),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _selectionCard(String title, IconData icon, String desc) {
    return GestureDetector(
      onTap: () => _onDiseaseSelect(title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: const Color(0xFF00AACD), size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(fontSize: 13, color: subTextColor)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputStep() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildStepHeader('Prediction Inputs'),
        const SizedBox(height: 20),
        _buildPresetSelector(),
        const SizedBox(height: 20),
        _buildMetricsCard(),
        const SizedBox(height: 32),
        if (_selectedDisease == 'Heart Disease') ..._buildHeartInputs(),
        if (_selectedDisease == 'Kidney Disease') ..._buildKidneyInputs(),
        if (_selectedDisease == 'Diabetes') ..._buildDiabetesInputs(),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _isAnalyzing ? null : _analyzeResults,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00AACD),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _isAnalyzing
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Generate Prediction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  List<Widget> _buildHeartInputs() {
    return [
      _buildToggle('Had Angina', 'HadAngina'),
      _buildToggle('Chest Scan', 'ChestScan'),
      _buildToggle('Had Stroke', 'HadStroke'),
      _buildToggle('Difficulty Walking', 'DifficultyWalking'),
      _buildToggle('Had Diabetes', 'HadDiabetes'),
      _buildDropdown('General Health', 'GeneralHealth', ['Excellent', 'Very good', 'Good', 'Fair', 'Poor']),
      _buildToggle('Had Arthritis', 'HadArthritis'),
      _buildToggle('Pneumonia Vaccine Ever', 'PneumoVaxEver'),
      _buildDropdown('Removed Teeth', 'RemovedTeeth', ['None of them', '1 to 5', '6 or more but not all', 'All']),
      _buildDropdown('Age Category', 'AgeCategory', ['Age 18 to 24', 'Age 25 to 29', 'Age 30 to 34', 'Age 35 to 39', 'Age 40 to 44', 'Age 45 to 49', 'Age 50 to 54', 'Age 55 to 59', 'Age 60 to 64', 'Age 65 to 69', 'Age 70 to 74', 'Age 75 to 79', 'Age 80 or older']),
      _buildDropdown('Smoker Status', 'SmokerStatus', ['Never smoked', 'Former smoker', 'Current smoker - now smokes every day', 'Current smoker - now smokes some days']),
      _buildTextField('BMI (Body Mass Index)', 'BMI', 'Normal: 18.5–24.9'),
      _buildToggle('Kidney Disease', 'HadKidneyDisease'),
      _buildToggle('COPD (Lung Disease)', 'HadCOPD'),
    ];
  }

  List<Widget> _buildKidneyInputs() {
    return [
      _buildTextField('Age', 'age', ''),
      _buildTextField('Blood Pressure', 'bp', 'Normal < 120'),
      _buildTextField('Specific Gravity', 'sg', '1.010–1.025'),
      _buildDropdown('Albumin (0-5)', 'al', ['0', '1', '2', '3', '4', '5']),
      _buildDropdown('Sugar (0-5)', 'su', ['0', '1', '2', '3', '4', '5']),
      _buildDropdown('Red Blood Cells', 'rbc', ['normal', 'abnormal']),
      _buildDropdown('Pus Cell', 'pc', ['normal', 'abnormal']),
      _buildDropdown('Pus Cell Clumps', 'pcc', ['notpresent', 'present']),
      _buildDropdown('Bacteria', 'ba', ['notpresent', 'present']),
      _buildTextField('Blood Glucose Random', 'bgr', 'Normal < 140'),
      _buildTextField('Blood Urea', 'bu', 'Normal < 40'),
      _buildTextField('Serum Creatinine', 'sc', 'Normal 0.6–1.2'),
      _buildTextField('Sodium', 'sod', 'Normal 135–145'),
      _buildTextField('Potassium', 'pot', 'Normal 3.5–5.0'),
      _buildTextField('Hemoglobin', 'hemo', 'Normal 12–17'),
      _buildTextField('Packed Cell Volume', 'pcv', 'Normal 36–50'),
      _buildTextField('White Blood Cell Count', 'wc', 'Normal 4000–11000'),
      _buildTextField('Red Blood Cell Count', 'rc', 'Normal 4.5–5.5'),
      _buildToggle('Hypertension', 'htn'),
      _buildToggle('Diabetes', 'dm'),
      _buildToggle('Coronary Artery Disease', 'cad'),
      _buildDropdown('Appetite', 'appet', ['good', 'poor']),
      _buildToggle('Pedal Edema', 'pe'),
      _buildToggle('Anemia', 'ane'),
    ];
  }

  List<Widget> _buildDiabetesInputs() {
    return [
      _buildTextField('HbA1c Level', 'HbA1c_level', 'Normal: 4.0-5.6'),
      _buildTextField('Blood Glucose Level', 'blood_glucose_level', 'Normal: 70-99'),
      _buildTextField('Age', 'age', ''),
      _buildTextField('BMI (Body Mass Index)', 'bmi', 'Normal: 18.5-24.9'),
      _buildDropdown('Smoking History', 'smoking_history', ['never', 'former', 'current', 'not current', 'ever']),
      _buildToggle('Hypertension', 'hypertension', true), // Uses 1/0
      _buildDropdown('Gender', 'gender', ['Male', 'Female']),
      _buildToggle('Heart Disease', 'heart_disease', true), // Uses 1/0
    ];
  }

  Widget _buildToggle(String label, String key, [bool useInt = false]) {
    dynamic value = _inputs[key];
    bool boolValue = false;
    
    if (value is bool) boolValue = value;
    else if (value == 1 || value == 'Yes' || value == 'yes') boolValue = true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
            Row(
              children: [
                Text(boolValue ? 'Yes' : 'No', style: TextStyle(color: boolValue ? const Color(0xFF00AACD) : const Color(0xFF94A3B8), fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(width: 8),
                Switch(
                  value: boolValue,
                  onChanged: (val) {
                    setState(() {
                      if (useInt) {
                        _inputs[key] = val ? 1 : 0;
                      } else {
                        // For Kidney/Heart models, they usually want 'yes'/'no' or 'Yes'/'No'
                        // Based on schemas.py examples: Kidney uses 'no', Heart uses 'Yes'
                        if (_selectedDisease == 'Kidney Disease') {
                          _inputs[key] = val ? 'yes' : 'no';
                        } else {
                          _inputs[key] = val ? 'Yes' : 'No';
                        }
                      }
                    });
                  },
                  activeColor: const Color(0xFF00AACD),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String key, List<String> options) {
    String? value = _inputs[key]?.toString();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: (value != null && options.contains(value)) ? value : null,
                isExpanded: true,
                hint: const Text('Select Option', style: TextStyle(fontSize: 14)),
                items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                onChanged: (val) => setState(() => _inputs[key] = val),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String key, String range) {
    final controller = _getController(key);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)))),
              if (range.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(range, style: const TextStyle(fontSize: 11, color: Color(0xFF00AACD), fontWeight: FontWeight.w500)),
              ],
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (val) {
              // Store parsed value; keep controller text as-is so cursor stays
              final parsed = double.tryParse(val);
              if (parsed != null) _inputs[key] = parsed;
            },
            decoration: InputDecoration(
              hintText: 'Enter value',
              filled: true,
              fillColor: cardColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF00AACD), width: 1.5)),
              contentPadding: const EdgeInsets.all(18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_fix_high_rounded, color: const Color(0xFF00AACD), size: 16),
              const SizedBox(width: 6),
              Text('Quick Fill Preset', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(width: 4),
              Text('(auto-fills all fields)', style: TextStyle(fontSize: 11, color: subTextColor)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _presetBtn('Healthy',   'healthy',   const Color(0xFF22C55E), Icons.check_circle_rounded),
              const SizedBox(width: 8),
              _presetBtn('At Risk',   'risk',      const Color(0xFFF59E0B), Icons.warning_amber_rounded),
              const SizedBox(width: 8),
              _presetBtn('Unhealthy', 'unhealthy', const Color(0xFFEF4444), Icons.dangerous_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _presetBtn(String label, String level, Color color, IconData icon) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _applyPreset(level),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsCard() {
    final metrics = _modelMetrics[_selectedDisease]!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: textColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: Color(0xFF00AACD), size: 20),
              const SizedBox(width: 10),
              Text('$_selectedDisease AI Model', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: metrics.entries.map((e) => Column(
              children: [
                Text(e.value, style: const TextStyle(color: Color(0xFF00AACD), fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(e.key, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultStep() {
    final riskLabel = _getRiskLabel(_riskScore);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildStepHeader('Prediction Result'),
          const SizedBox(height: 32),

          // ── Status Banner ───────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_statusColor.withOpacity(0.15), _statusColor.withOpacity(0.03)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: _statusColor.withOpacity(0.35), width: 1.5),
              boxShadow: [BoxShadow(color: _statusColor.withOpacity(0.15), blurRadius: 30, spreadRadius: 2)],
            ),
            child: Column(
              children: [
                // Icon circle
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: _statusColor.withOpacity(0.4), width: 2),
                  ),
                  child: Icon(_statusIcon, color: _statusColor, size: 48),
                ),
                const SizedBox(height: 20),
                // Status title
                Text(
                  _statusTitle,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: _statusColor, letterSpacing: 3),
                ),
                const SizedBox(height: 8),
                // Probability
                Text(
                  '${_riskScore.toInt()}% probability',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 4),
                // Risk label badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(riskLabel, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _statusColor)),
                ),
                const SizedBox(height: 16),
                // Subtitle
                Text(
                  _statusSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: subTextColor, height: 1.5),
                ),
                if (_riskDescription.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _riskDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: subTextColor.withOpacity(0.7), fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Three-state summary chips ───────────────────────────────────
          Row(
            children: [
              _statChip('Healthy',   'healthy',   const Color(0xFF22C55E), Icons.check_circle_rounded),
              const SizedBox(width: 8),
              _statChip('At Risk',   'risk',      const Color(0xFFF59E0B), Icons.warning_amber_rounded),
              const SizedBox(width: 8),
              _statChip('Unhealthy', 'unhealthy', const Color(0xFFEF4444), Icons.dangerous_rounded),
            ],
          ),

          const SizedBox(height: 24),

          if (_inputs.isNotEmpty) ...[
            _buildProvidedInputsSummary(),
            const SizedBox(height: 20),
          ],
          _buildResultInfoCard(),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: OutlinedButton(
                    onPressed: () => setState(() => _currentStep = 0),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: textColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Back', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => _saveToHistory(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00AACD),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Save Result', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _statChip(String label, String level, Color color, IconData icon) {
    final isActive = _statusLevel == level;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.15) : cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? color : borderColor,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isActive ? color : subTextColor, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isActive ? color : subTextColor)),
          ],
        ),
      ),
    );
  }

  Future<void> _saveToHistory() async {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${months[now.month - 1]} ${now.day}, ${now.year}';

    healixStore.addRecord({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': '$_selectedDisease: ${_statusTitle} (${_riskScore.toInt()}%)',
      'date': dateStr,
      'type': 'AI Prediction',
      'status': _statusTitle,
      'isAi': true,
      'riskScore': _riskScore.toInt(),
      'statusLevel': _statusLevel,
      'inputs': Map<String, dynamic>.from(_inputs),
      'disease': _selectedDisease,
    });

    // Save results to store for doctor and dashboard recent analysis to see
    final aiResultData = {
      'riskScore': _riskScore,
      'statusLevel': _statusLevel,
      'riskDescription': _riskDescription,
      'disease': _selectedDisease,
      'inputs': Map<String, dynamic>.from(_inputs),
      'timestamp': DateTime.now().toIso8601String(),
      'patientName': healixStore.userName.value,
      'patientId': healixStore.patientId.value,
    };
    healixStore.saveAiResult(healixStore.userName.value, aiResultData);

    // Persist to backend so doctors can view full history for any patient
    final patientId = healixStore.patientId.value;
    if (patientId != null) {
      await patientService.saveAiAnalysis({
        'patientId': int.tryParse(patientId) ?? patientId,
        'disease': _selectedDisease,
        'prediction': (_analysisResult?['prediction'] as num?)?.toInt() ?? 0,
        'probability': _riskScore,
        'riskLevel': _statusLevel,
        'statusLevel': _statusLevel,
        'riskDescription': _riskDescription,
        'inputs': Map<String, dynamic>.from(_inputs),
        'modelVersion': _analysisResult?['model_version'],
      });
    }

    // If patient has a subscribed doctor or booked doctor, forward the result to them
    final subDoc = healixStore.subscribedDoctor.value;
    final lastAppt = healixStore.lastAppointment.value;

    if (subDoc != null || lastAppt != null) {
      final dName = subDoc != null
          ? "Dr. ${subDoc['firstName'] ?? ''} ${subDoc['lastName'] ?? ''}".trim()
          : (lastAppt!['doctorName'] ?? 'Doctor');
      
      // Notify the patient that result was forwarded
      healixStore.addNotification(
        'Result sent to $dName',
        'Your $_selectedDisease analysis has been forwarded to your doctor.',
        type: 'ai_result',
        target: 'patient',
      );
      // Also notify the doctor (will appear in doctor's notification bell)
      healixStore.addNotification(
        'New AI Result from ${healixStore.userName.value}',
        '${healixStore.userName.value} has shared a $_selectedDisease risk analysis with you.',
        type: 'patient_ai_result',
        target: 'doctor',
        metadata: {'patientName': healixStore.userName.value, ...aiResultData},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Result saved & sent to $dName'),
            backgroundColor: const Color(0xFF007580),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Result saved to Medical History! Tip: Book a doctor or subscribe to share results automatically.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
    
    setState(() => _currentStep = 0);
  }

  Widget _buildProvidedInputsSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Patient Inputs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
          const SizedBox(height: 16),
          ..._inputs.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(e.key, style: TextStyle(color: subTextColor, fontSize: 13))),
                  Text('${e.value}', style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13)),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildResultInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF00AACD)),
              SizedBox(width: 12),
              Text('Medical Disclaimer', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'This prediction is based on AI algorithms and should not be taken as a final medical diagnosis. Please consult with a healthcare professional.',
            style: TextStyle(color: subTextColor, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => setState(() => _currentStep--),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
        ),
      ],
    );
  }
}
