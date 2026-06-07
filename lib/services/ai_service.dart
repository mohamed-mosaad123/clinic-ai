import '../core/network/api_service.dart';

class AIService {
  final ApiService _api = ApiService();

  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  Future<Map<String, dynamic>?> predict({
    required String diseaseType,
    required Map<String, dynamic> features,
  }) async {
    try {
      final response = await _api.post('/diagnosis/predict', data: {
        'disease': diseaseType,
        'data': features,
      });
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getHealth() async {
    try {
      final response = await _api.get('/diagnosis/health');
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> saveAnalysis(Map<String, dynamic> payload) async {
    try {
      final response = await _api.post('/diagnosis/analyses', data: payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAnalysesByPatient(String patientId) async {
    try {
      final response = await _api.get('/diagnosis/analyses/patient/$patientId');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllAnalyses() async {
    try {
      final response = await _api.get('/diagnosis/analyses');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

final aiService = AIService();
