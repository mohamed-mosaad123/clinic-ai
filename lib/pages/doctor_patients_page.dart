import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'doctor_profile_page.dart';
import 'patient_record_detail_page.dart';

import '../services/doctor_service.dart';
import '../store/healix_store.dart';

class DoctorPatientsPage extends StatefulWidget {
  const DoctorPatientsPage({super.key});

  @override
  State<DoctorPatientsPage> createState() => _DoctorPatientsPageState();
}

class _DoctorPatientsPageState extends State<DoctorPatientsPage> {
  List<Map<String, dynamic>> _patients = [];
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _subscribedPatientsFromStore = [];
  bool _isLoading = true;
  String _selectedFilter = 'All Patients';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  String _getPatientName(Map<String, dynamic> pt) {
    final first = pt['firstName'] ?? pt['FirstName'] ?? '';
    final last = pt['lastName'] ?? pt['LastName'] ?? '';
    final name = "$first $last".trim();
    return name.isNotEmpty ? name : 'Unknown Patient';
  }

  String _getPatientId(Map<String, dynamic> pt) {
    return (pt['id'] ?? pt['Id'] ?? 'N/A').toString();
  }

  String _getPatientEmail(Map<String, dynamic> pt) {
    return (pt['email'] ?? pt['Email'] ?? '').toString();
  }

  Future<void> _fetchData() async {
    // Fetch all patients from database
    final pts = await doctorService.getPatients();

    // Fetch appointments for this doctor (for Recently Visited filter)
    List<Map<String, dynamic>> apps = [];
    final dId = healixStore.doctorId.value;
    if (dId != null) {
      try {
        apps = await doctorService.getAppointments(dId);
      } catch (_) {}
    }

    // Fetch subscribed patients for this doctor from store
    List<Map<String, dynamic>> subs = [];
    if (dId != null) {
      final prefs = await SharedPreferences.getInstance();
      final subKey = 'subscribed_patients_$dId';
      final existingJson = prefs.getString(subKey);
      if (existingJson != null) {
        try {
          final list = jsonDecode(existingJson) as List<dynamic>;
          subs = list.map((item) => Map<String, dynamic>.from(item)).toList();
        } catch (_) {}
      }
    }

    if (mounted) {
      setState(() {
        _patients = pts;
        _appointments = apps;
        _subscribedPatientsFromStore = subs;
        _isLoading = false;
      });
    }
  }

  bool _isPatientSubscribed(Map<String, dynamic> pt) {
    final name = _getPatientName(pt).toLowerCase();
    final idStr = _getPatientId(pt).toLowerCase();

    // Check if in SharedPreferences subscribed list
    final inStore = _subscribedPatientsFromStore.any((sub) {
      final subId = (sub['id'] ?? '').toString().toLowerCase();
      final subName = (sub['name'] ?? '').toString().toLowerCase();
      return subId == idStr || subName == name;
    });
    if (inStore) return true;

    // Check fallback AI results shared
    return healixStore.patientAiResults.value.entries.any((entry) {
      final entryKey = entry.key.toLowerCase();
      final valName = (entry.value['patientName'] as String?)?.toLowerCase() ?? '';
      return entryKey == idStr || entryKey == name || valName == name;
    });
  }

  bool _isPatientRecentlyVisited(Map<String, dynamic> pt) {
    final name = _getPatientName(pt).toLowerCase();
    final idStr = _getPatientId(pt).toLowerCase();

    // Check backend appointments from DB
    final inBackend = _appointments.any((app) {
      final appName = ((app['patientName'] ?? app['PatientName']) as String?)?.toLowerCase() ?? '';
      final appPtId = (app['patientId'] ?? app['PatientId'] ?? '').toString();
      return appPtId == idStr || (appName.isNotEmpty && appName.contains(name)) || (name.isNotEmpty && name.contains(appName));
    });
    if (inBackend) return true;

    // Check local runtime appointments (newly booked this session)
    return healixStore.doctorAppointments.value.any((app) {
      final appName = ((app['patientName'] ?? app['PatientName']) as String?)?.toLowerCase() ?? '';
      final appPtId = (app['patientId'] ?? app['PatientId'] ?? '').toString();
      return appPtId == idStr || (appName.isNotEmpty && appName.contains(name)) || (name.isNotEmpty && name.contains(appName));
    });
  }

  List<Map<String, dynamic>> get _visibleDoctorPatients {
    // Show all registered patients in the system
    return _patients;
  }

  List<Map<String, dynamic>> get _filteredPatients {
    List<Map<String, dynamic>> filtered = _visibleDoctorPatients;

    // Apply tab filter
    if (_selectedFilter == 'Subscribed') {
      filtered = filtered.where(_isPatientSubscribed).toList();
    } else if (_selectedFilter == 'Recently Visited') {
      filtered = filtered.where(_isPatientRecentlyVisited).toList();
    }
    // 'All Patients' → show all visible patients

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((pt) {
        final fullName = _getPatientName(pt).toLowerCase();
        final id = _getPatientId(pt).toLowerCase();
        final email = _getPatientEmail(pt).toLowerCase();
        return fullName.contains(query) || id.contains(query) || email.contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.blueGrey.shade400;
    final borderColor = isDark ? Colors.white10 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF00C4D4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.security, color: Colors.white, size: 18),
          ),
        ),
        title: Image.asset(
          'assets/images/logo_full.jpeg',
          height: 32,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: isDark ? Colors.white70 : const Color(0xFF334155)),
            onPressed: () {},
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorProfilePage()));
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: TextField(
                style: TextStyle(color: textColor),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: subTextColor),
                  hintText: 'Search by name, ID, or condition',
                  hintStyle: TextStyle(color: subTextColor, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _selectedFilter = 'Recently Visited'),
                    child: _buildFilterChip('Recently Visited', _selectedFilter == 'Recently Visited', isDark),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _selectedFilter = 'Subscribed'),
                    child: _buildFilterChip('Subscribed', _selectedFilter == 'Subscribed', isDark),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _selectedFilter = 'All Patients'),
                    child: _buildFilterChip('All Patients', _selectedFilter == 'All Patients', isDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Stats
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF007580).withOpacity(0.15) : const Color(0xFFE0FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: isDark ? Border.all(color: const Color(0xFF007580).withOpacity(0.3)) : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TOTAL PATIENTS', style: TextStyle(color: Color(0xFF007580), fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${_visibleDoctorPatients.length}', style: const TextStyle(color: Color(0xFF007580), fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF007580).withOpacity(0.15) : const Color(0xFFE0FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: isDark ? Border.all(color: const Color(0xFF007580).withOpacity(0.3)) : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('SUBSCRIBED', style: TextStyle(color: Color(0xFF007580), fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${_visibleDoctorPatients.where(_isPatientSubscribed).length}', style: const TextStyle(color: Color(0xFF007580), fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.orange.withOpacity(0.15) : const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(16),
                      border: isDark ? Border.all(color: Colors.orange.withOpacity(0.3)) : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('UNSUBSCRIBED', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${_visibleDoctorPatients.where((p) => !_isPatientSubscribed(p)).length}', style: const TextStyle(color: Colors.orange, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Patient Cards
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_filteredPatients.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _selectedFilter == 'Subscribed'
                              ? Icons.notifications_off_outlined
                              : _selectedFilter == 'Recently Visited'
                                  ? Icons.history_toggle_off
                                  : Icons.person_search_outlined,
                          size: 40,
                          color: isDark ? Colors.white24 : Colors.blueGrey.shade300,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedFilter == 'Subscribed'
                            ? 'No subscribed patients'
                            : _selectedFilter == 'Recently Visited'
                                ? 'No recently visited patients'
                                : 'No patients yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white54 : Colors.blueGrey.shade400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedFilter == 'All Patients'
                            ? 'Patients will appear here once they\nbook an appointment or subscribe to you.'
                            : 'Try the All Patients tab to see\neveryone connected to you.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white38 : Colors.blueGrey.shade300,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._filteredPatients.map((pt) {
                final fullName = _getPatientName(pt);
                final id = _getPatientId(pt);
                final isPtSubscribed = _isPatientSubscribed(pt);
                final isVisited = _isPatientRecentlyVisited(pt);
                return _buildPatientCard(
                  context: context,
                  patientData: pt,
                  name: fullName,
                  id: '#$id',
                  status: isPtSubscribed ? 'Subscribed' : 'Not Subscribed',
                  statusColor: isPtSubscribed 
                      ? const Color(0xFF007580) 
                      : Colors.grey.shade500,
                  isUrgent: false,
                  dateOrTime: 'N/A',
                  dateIcon: Icons.calendar_today,
                  condition: 'Consultation',
                  conditionIcon: Icons.monitor_heart_outlined,
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  borderColor: borderColor,
                  isVisited: isVisited,
                );
              }).toList(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF007580) : (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? const Color(0xFF007580) : (isDark ? Colors.white12 : Colors.grey.shade300)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : (isDark ? Colors.grey.shade300 : Colors.blueGrey.shade700),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildPatientCard({
    required BuildContext context,
    required Map<String, dynamic> patientData,
    required String name, required String id, required String status,
    required Color statusColor,
    required bool isUrgent,
    required String dateOrTime, required IconData dateIcon, required String condition, required IconData conditionIcon,
    required bool isDark, required Color cardColor, required Color textColor, required Color subTextColor, required Color borderColor,
    required bool isVisited,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientRecordDetailPage(
              patientName: name,
              patientId: id,
              patientData: patientData,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5)),
          ],
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'P',
                        style: TextStyle(color: statusColor, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                        Text('ID: $id', style: TextStyle(fontSize: 12, color: subTextColor)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  if (isVisited) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF845EF7).withOpacity(isDark ? 0.2 : 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Visited',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF845EF7),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey.shade100),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildActionIcon(Icons.description, isDark: isDark),
                  const SizedBox(width: 8),
                  _buildActionIcon(Icons.medical_services, isTeal: true, isDark: isDark),
                  const SizedBox(width: 8),
                  _buildActionIcon(Icons.history, isDark: isDark),
                  const Spacer(),
                  Text('View Record', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor)),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: statusColor, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, {bool isTeal = false, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isTeal
            ? (isDark ? const Color(0xFF007580).withOpacity(0.15) : const Color(0xFFE0FAFC))
            : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: isTeal ? const Color(0xFF007580) : (isDark ? Colors.white54 : const Color(0xFF334155))),
    );
  }
}
