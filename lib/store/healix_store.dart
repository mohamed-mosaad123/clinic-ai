import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class HealixStore {
  static final HealixStore _instance = HealixStore._internal();
  factory HealixStore() => _instance;
  HealixStore._internal();

  final ValueNotifier<Map<String, dynamic>?> lastAppointment = ValueNotifier<Map<String, dynamic>?>(null);
  final ValueNotifier<String> userName = ValueNotifier<String>('User');
  final ValueNotifier<String?> profileImageUrl = ValueNotifier<String?>(null);
  final ValueNotifier<String?> patientId = ValueNotifier<String?>(null);
  final ValueNotifier<String?> doctorId = ValueNotifier<String?>(null);
    /// Logs in as the given patient/account ID.
  /// This method sets the current patientId, clears any previously loaded
  /// local records (so data from another account does not leak), and then
  /// loads the persisted data for the new patient.
  Future<void> loginAsPatient(String? id) async {
    // If switching to a different patient, clear in‑memory records.
    if (patientId.value != id) {
      // Clear current in‑memory lists.
      localRecords.clear();
      historyRecords.value = [];
    }
    await setCurrentPatientId(id);
    // setCurrentPatientId already loads persisted data scoped to the new patient.
  }



  // Subscribed doctor (patient subscribes to a doctor to receive reports)
  final ValueNotifier<Map<String, dynamic>?> subscribedDoctor = ValueNotifier<Map<String, dynamic>?>(null);
  
  final ValueNotifier<List<Map<String, dynamic>>> historyRecords = ValueNotifier<List<Map<String, dynamic>>>([]);
  final List<Map<String, dynamic>> localRecords = [];
  final ValueNotifier<List<Map<String, dynamic>>> notifications = ValueNotifier<List<Map<String, dynamic>>>([]);
  final ValueNotifier<List<Map<String, dynamic>>> doctorAppointments = ValueNotifier<List<Map<String, dynamic>>>([]);
  final ValueNotifier<Map<String, Map<String, dynamic>>> patientAiResults = ValueNotifier<Map<String, Map<String, dynamic>>>({});
  final ValueNotifier<Map<String, List<Map<String, dynamic>>>> patientReports = ValueNotifier<Map<String, List<Map<String, dynamic>>>>({});

  void setAppointment(String doctorName, String date, String time) {
    lastAppointment.value = {
      'doctorName': doctorName,
      'date': date,
      'time': time,
    };
  }

  Future<void> subscribeToDoctor(Map<String, dynamic> doctor) async {
    subscribedDoctor.value = doctor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('subscribed_doctor', jsonEncode(doctor));

    // Persist this patient subscription for the doctor
    final docId = (doctor['id'] ?? doctor['personId'] ?? '').toString();
    if (docId.isNotEmpty) {
      final patientName = userName.value;
      final currentPatId = patientId.value ?? 'guest';
      final subKey = 'subscribed_patients_$docId';
      final existingJson = prefs.getString(subKey);
      List<dynamic> subList = [];
      if (existingJson != null) {
        try {
          subList = jsonDecode(existingJson) as List<dynamic>;
        } catch (_) {}
      }
      
      bool exists = subList.any((p) => p['id'] == currentPatId || p['name'] == patientName);
      if (!exists) {
        subList.add({
          'id': currentPatId,
          'name': patientName,
          'subscribedAt': DateTime.now().toIso8601String(),
        });
        await prefs.setString(subKey, jsonEncode(subList));
      }
    }

    // Notify the doctor
    final dName = "Dr. ${doctor['firstName'] ?? ''} ${doctor['lastName'] ?? ''}".trim();
    addNotification(
      'Subscribed to $dName',
      'You are now subscribed. Your AI analysis results will be shared with $dName.',
      type: 'subscription',
      target: 'patient',
    );
  }

  Future<void> unsubscribeFromDoctor() async {
    final doctor = subscribedDoctor.value;
    subscribedDoctor.value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('subscribed_doctor');

    if (doctor != null) {
      final docId = (doctor['id'] ?? doctor['personId'] ?? '').toString();
      if (docId.isNotEmpty) {
        final currentPatId = patientId.value ?? 'guest';
        final subKey = 'subscribed_patients_$docId';
        final existingJson = prefs.getString(subKey);
        if (existingJson != null) {
          try {
            List<dynamic> subList = jsonDecode(existingJson) as List<dynamic>;
            subList.removeWhere((p) => p['id'] == currentPatId || p['name'] == userName.value);
            await prefs.setString(subKey, jsonEncode(subList));
          } catch (_) {}
        }
      }
    }
  }

  Future<void> addDoctorAppointment(Map<String, dynamic> appointment) async {
    doctorAppointments.value = [...doctorAppointments.value, appointment];
    _saveDoctorAppointments();
  }

  Future<void> removeDoctorAppointment(String patientName, String date) async {
    final updated = List<Map<String, dynamic>>.from(doctorAppointments.value);
    updated.removeWhere((app) => 
      app['patientName'] == patientName && 
      app['appointmentDate'].toString().contains(date)
    );
    doctorAppointments.value = updated;
    _saveDoctorAppointments();
  }

  Future<void> updateDoctorAppointmentStatus(String patientName, String date, String status) async {
    final updated = List<Map<String, dynamic>>.from(doctorAppointments.value);
    for (var app in updated) {
      if (app['patientName'] == patientName && app['appointmentDate'].toString().contains(date)) {
        app['status'] = status;
      }
    }
    doctorAppointments.value = updated;
    _saveDoctorAppointments();
  }

  Future<void> saveAiResult(String patientName, Map<String, dynamic> result) async {
    final key = patientId.value ?? patientName;
    final updated = Map<String, Map<String, dynamic>>.from(patientAiResults.value);
    updated[key] = result;
    if (key != patientName) {
      updated[patientName] = result;
    }
    patientAiResults.value = updated;
    _saveAiResults();
  }

  Future<void> addPatientReport(String patientName, Map<String, dynamic> report) async {
    final key = patientId.value ?? patientName;
    final updated = Map<String, List<Map<String, dynamic>>>.from(patientReports.value);
    final reportsList = updated[key] ?? [];
    updated[key] = [report, ...reportsList];
    if (key != patientName) {
      final reportsName = updated[patientName] ?? [];
      updated[patientName] = [report, ...reportsName];
    }
    patientReports.value = updated;
    _saveReports();
  }

  /// [target] must be 'patient' or 'doctor' so the UI can filter correctly.
  Future<void> addNotification(String title, String message, {String type = 'general', String target = 'all', Map<String, dynamic>? metadata}) async {
    notifications.value = [
      {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title,
        'message': message,
        'type': type,
        'target': target,
        'metadata': metadata,
        'time': 'Just now',
        'isRead': false,
      },
      ...notifications.value
    ];
    _saveNotifications();
  }

  Future<void> _saveAiResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_aiResultsKey(), jsonEncode(patientAiResults.value));
  }

  Future<void> _saveReports() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reportsKey(), jsonEncode(patientReports.value));
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_notifications', jsonEncode(notifications.value));
  }

  Future<void> _saveDoctorAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_doctor_appointments', jsonEncode(doctorAppointments.value));
  }

  Future<void> loadPersistedData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final notifsJson = prefs.getString('saved_notifications');
    if (notifsJson != null) {
      notifications.value = List<Map<String, dynamic>>.from(jsonDecode(notifsJson));
    }

    final appsJson = prefs.getString('saved_doctor_appointments');
    if (appsJson != null) {
      doctorAppointments.value = List<Map<String, dynamic>>.from(jsonDecode(appsJson));
    }

    final aiResultsJson = prefs.getString(_aiResultsKey());
    if (aiResultsJson != null) {
      patientAiResults.value = Map<String, Map<String, dynamic>>.from(jsonDecode(aiResultsJson));
    }

    final reportsJson = prefs.getString(_reportsKey());
    if (reportsJson != null) {
      final raw = jsonDecode(reportsJson) as Map<String, dynamic>;
      final updated = <String, List<Map<String, dynamic>>>{};
      raw.forEach((key, value) {
        updated[key] = List<Map<String, dynamic>>.from(value);
      });
      patientReports.value = updated;
    }

    final localRecsJson = prefs.getString(_localHistoryKey());
    if (localRecsJson != null) {
      localRecords.clear();
      localRecords.addAll(List<Map<String, dynamic>>.from(jsonDecode(localRecsJson)));
    }
    historyRecords.value = [...localRecords];

    // Load subscribed doctor
    final subDocJson = prefs.getString('subscribed_doctor');
    if (subDocJson != null) {
      subscribedDoctor.value = Map<String, dynamic>.from(jsonDecode(subDocJson));
    }
  }

  /// Sets the current patient ID and loads its persisted data.
  Future<void> setCurrentPatientId(String? id) async {
    patientId.value = id;
    await loadPersistedData();
  }

  /// Saves the local history records for the current patient.
  Future<void> _saveLocalRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localHistoryKey(), jsonEncode(localRecords));
  }

  String _localHistoryKey() => 'local_history_records_${patientId.value ?? "guest"}';

  String _aiResultsKey() => 'saved_ai_results_global';
  String _reportsKey() => 'saved_patient_reports_global';

  void setHistoryRecords(List<Map<String, dynamic>> backendRecords) {
    historyRecords.value = [...localRecords, ...backendRecords];
  }

  void setUserName(String name) {
    userName.value = name;
  }

  void removeRecord(String id) {
    localRecords.removeWhere((record) => record['id'] == id);
    _saveLocalRecords();
    historyRecords.value = List.from(historyRecords.value)..removeWhere((record) => record['id'] == id);
  }

  void addRecord(Map<String, dynamic> record) {
    localRecords.insert(0, record);
    _saveLocalRecords();
    historyRecords.value = [record, ...historyRecords.value];
  }

  void clearNotification(String id) {
    notifications.value = notifications.value.where((n) => n['id'] != id).toList();
    _saveNotifications();
  }

  void clearNotifications() {
    notifications.value = [];
    _saveNotifications();
  }
}

final healixStore = HealixStore();
