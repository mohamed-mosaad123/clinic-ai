import '../core/network/api_service.dart';

class DoctorService {
  final ApiService _api = ApiService();

  static final DoctorService _instance = DoctorService._internal();
  factory DoctorService() => _instance;
  DoctorService._internal();

  Future<List<Map<String, dynamic>>> getDoctors() async {
    try {
      final response = await _api.get('/doctors');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getDoctorById(int id) async {
    try {
      final response = await _api.get('/doctors/$id');
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getSpecializations() async {
    try {
      final response = await _api.get('/specializations');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAppointments(String doctorId) async {
    try {
      final response = await _api.get('/appointments/doctor/$doctorId');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPatients() async {
    try {
      final response = await _api.get('/patients');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> completeAppointment(int appointmentId) async {
    try {
      final response = await _api.put('/appointments/$appointmentId/Complete');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getPatientAiAnalyses(String patientId) async {
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

  Future<List<Map<String, dynamic>>> getAllAiAnalyses() async {
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

final doctorService = DoctorService();
