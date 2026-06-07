import '../core/network/api_service.dart';

class ScheduleService {
  final ApiService _api = ApiService();

  static final ScheduleService _instance = ScheduleService._internal();
  factory ScheduleService() => _instance;
  ScheduleService._internal();

  // Fetch schedules for a specific date
  Future<List<Map<String, dynamic>>> getSchedulesByDate(String doctorId, String date) async {
    try {
      final response = await _api.get('/schedules', queryParameters: {
        'doctorId': doctorId,
        'date': date,
      });
      
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Create a new schedule slot
  Future<bool> createScheduleSlot(Map<String, dynamic> data) async {
    try {
      final response = await _api.post('/schedules', data: data);
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

final scheduleService = ScheduleService();
