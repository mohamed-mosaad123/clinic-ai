import 'package:flutter/material.dart';
import 'patient_record_detail_page.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../services/doctor_service.dart';
import '../store/healix_store.dart';

class DoctorSchedulePage extends StatefulWidget {
  const DoctorSchedulePage({super.key});

  @override
  State<DoctorSchedulePage> createState() => _DoctorSchedulePageState();
}

class _DoctorSchedulePageState extends State<DoctorSchedulePage> {
  DateTime _selectedDate = DateTime.now();
  final List<String> _weekDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  List<Map<String, dynamic>> _allAppointments = [];
  bool _isLoading = true;

  final List<String> _timelineSlots = [
    '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM',
    '12:00 PM', '12:30 PM', '01:00 PM', '01:30 PM', '02:00 PM', '02:30 PM',
    '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM'
  ];

  TimeOfDay _parseTime(String slot) {
    final parts = slot.trim().split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
    if (parts.length > 1) {
      if (parts[1].toUpperCase() == 'PM' && hour != 12) hour += 12;
      if (parts[1].toUpperCase() == 'AM' && hour == 12) hour = 0;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadSelectedDate();
    await _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    final dId = healixStore.doctorId.value;
    if (dId != null) {
      if (mounted) setState(() => _isLoading = true);
      final apps = await doctorService.getAppointments(dId);
      if (mounted) {
        setState(() {
          _allAppointments = apps;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSelectedDate() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedDate = prefs.getString('selected_schedule_date');
    if (savedDate != null && mounted) {
      setState(() {
        _selectedDate = DateTime.parse(savedDate);
      });
    }
  }

  Future<void> _saveSelectedDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_schedule_date', date.toIso8601String());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredApps = _allAppointments.where((app) {
      final appDate = DateTime.tryParse(app['appointmentDate'] ?? '') ?? DateTime.now();
      return appDate.day == _selectedDate.day && 
             appDate.month == _selectedDate.month && 
             appDate.year == _selectedDate.year;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF00C4D4)),
          onPressed: () {},
        ),
        title: Image.asset(
          'assets/images/logo_full.jpeg',
          height: 30,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: healixStore.notifications,
            builder: (context, notifs, _) {
              final doctorNotifs = notifs.where((n) {
                final target = n['target'] ?? 'all';
                return target == 'doctor' || target == 'all';
              }).toList();
              final unreadCount = doctorNotifs.where((n) => !(n['isRead'] ?? false)).length;
              return Stack(alignment: Alignment.center, children: [
                IconButton(
                  icon: Icon(Icons.notifications_none, color: isDark ? Colors.white70 : const Color(0xFF334155)), 
                  onPressed: () {
                    _showNotifications(context, doctorNotifs);
                  }
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 12, top: 12,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                      child: Text(
                        unreadCount.toString(), 
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ]);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Schedule',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: healixStore.doctorAppointments,
              builder: (context, newApps, _) {
                final count = _allAppointments.where((app) {
                  final appDate = DateTime.tryParse(app['appointmentDate'] ?? '') ?? DateTime.now();
                  return appDate.day == _selectedDate.day && 
                         appDate.month == _selectedDate.month && 
                         appDate.year == _selectedDate.year;
                }).length + newApps.where((app) {
                  final appDate = DateTime.tryParse(app['appointmentDate'] ?? '') ?? DateTime.now();
                  return appDate.day == _selectedDate.day && 
                         appDate.month == _selectedDate.month && 
                         appDate.year == _selectedDate.year;
                }).length;
                
                return Text(
                  'You have $count consultations scheduled for ${_selectedDate.day}/${_selectedDate.month}.',
                  style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade400),
                );
              }
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.filter_list, size: 16, color: isDark ? Colors.white70 : const Color(0xFF0F172A)),
                      const SizedBox(width: 8),
                      Text('Filter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white70 : const Color(0xFF0F172A))),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C4D4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.add, size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('New Slot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildCalendarStrip(),
            const SizedBox(height: 24),
            _buildStatsGrid(),
            const SizedBox(height: 24),
            _buildDivider('UPCOMING FOR ${_weekDays[(_selectedDate.weekday - 1) % 7]}'),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: healixStore.doctorAppointments,
              builder: (context, newApps, _) {
                final dayNewApps = newApps.where((app) {
                  final appDate = DateTime.tryParse(app['appointmentDate'] ?? '');
                  if (appDate == null) return false;
                  return appDate.day == _selectedDate.day && 
                         appDate.month == _selectedDate.month && 
                         appDate.year == _selectedDate.year;
                }).toList();
                
                final dayFilteredApps = _allAppointments.where((app) {
                  final appDate = DateTime.tryParse(app['appointmentDate'] ?? '');
                  if (appDate == null) return false;
                  return appDate.day == _selectedDate.day && 
                         appDate.month == _selectedDate.month && 
                         appDate.year == _selectedDate.year;
                }).toList();

                final combined = [...dayNewApps, ...dayFilteredApps];

                return Column(
                  children: _timelineSlots.map((slot) {
                    final slotTime = _parseTime(slot);
                    // Find matching appointment
                    Map<String, dynamic>? matchedApp;
                    for (final app in combined) {
                      final appDateStr = app['appointmentDate'];
                      if (appDateStr == null) continue;
                      final appDate = DateTime.tryParse(appDateStr);
                      if (appDate != null && appDate.hour == slotTime.hour && appDate.minute == slotTime.minute) {
                        matchedApp = app;
                        break;
                      }
                    }

                    if (matchedApp != null) {
                      final date = DateTime.tryParse(matchedApp['appointmentDate'] ?? '') ?? DateTime.now();
                      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
                      final timeStr = "$hour:${date.minute.toString().padLeft(2, '0')}";
                      final period = date.hour >= 12 ? 'PM' : 'AM';
                      return _upcomingItem(
                        context, 
                        matchedApp,
                        timeStr, 
                        period, 
                        matchedApp['patientName'] ?? 'Unknown Patient', 
                        '${matchedApp['reason'] ?? 'Consultation'}', 
                        matchedApp['status'] ?? 'pending'
                      );
                    } else {
                      return _availableSlotItem(slot);
                    }
                  }).toList(),
                );
              }
            ),
            const SizedBox(height: 8),
            _buildDivider('PAST CONSULTATIONS'),
            const SizedBox(height: 16),
            _pastItem(context, '08:00\nAM', 'Elena Rodriguez', 'Follow-up Lab Results • 15 mins'),
            _pastItem(context, 'Yesterday\n04:30 PM', 'Marcus Chen', 'Prescription Renewal • 15 mins'),
            const SizedBox(height: 24),
            _buildAiInsightsCard(),
            const SizedBox(height: 80), // Padding for BottomNav
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarStrip() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14, // Show two weeks including weekends
        itemBuilder: (context, index) {
          final date = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).add(Duration(days: index));
          final isSelected = _selectedDate.day == date.day && _selectedDate.month == date.month;
          final isToday = DateTime.now().day == date.day && DateTime.now().month == date.month;
          
          return GestureDetector(
            onTap: () async {
              setState(() {
                _selectedDate = date;
              });
              await _saveSelectedDate(date);
            },
            child: Container(
              width: 65,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF007580) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isToday && !isSelected ? Border.all(color: const Color(0xFF00C4D4), width: 1.5) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekDays[date.weekday - 1],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white70 : Colors.blueGrey.shade300,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid() {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: healixStore.doctorAppointments,
      builder: (context, newApps, _) {
        final dayNewApps = newApps.where((app) {
          final appDate = DateTime.tryParse(app['appointmentDate'] ?? '') ?? DateTime.now();
          return appDate.day == _selectedDate.day && 
                 appDate.month == _selectedDate.month && 
                 appDate.year == _selectedDate.year;
        }).toList();

        final filteredApps = _allAppointments.where((app) {
          final appDate = DateTime.tryParse(app['appointmentDate'] ?? '') ?? DateTime.now();
          return appDate.day == _selectedDate.day && 
                 appDate.month == _selectedDate.month && 
                 appDate.year == _selectedDate.year;
        }).toList();

        final combined = [...dayNewApps, ...filteredApps];

        final completed = combined.where((app) => (app['status'] ?? 'pending') == 'completed').length;
        final confirmed = combined.where((app) => (app['status'] ?? 'pending') == 'confirmed').length;
        final pending = combined.where((app) => (app['status'] ?? 'pending') == 'pending').length;
        
        final total = combined.length;
        final efficiency = total > 0 ? ((completed + confirmed) / total * 100).round() : 100;
        final progressFactor = total > 0 ? (completed + confirmed) / total : 1.0;

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _statCard('COMPLETED', completed.toString().padLeft(2, '0'), const Color(0xFF007580), total > 0 ? completed / total : 0.0)),
                const SizedBox(width: 16),
                Expanded(child: _statCard('CONFIRMED', confirmed.toString().padLeft(2, '0'), const Color(0xFF007580), total > 0 ? confirmed / total : 0.0)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _statCard('PENDING', pending.toString().padLeft(2, '0'), Colors.orange, total > 0 ? pending / total : 0.0)),
                const SizedBox(width: 16),
                Expanded(child: _statCard('EFFICIENCY', '$efficiency%', Colors.black87, progressFactor)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _statCard(String title, String value, Color color, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade400, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 12),
          Container(
            height: 3,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(String text) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade400, letterSpacing: 0.5)),
        ),
        Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
      ],
    );
  }

  Widget _upcomingItem(BuildContext context, Map<String, dynamic> app, String time, String period, String name, String details, String status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Use real patient ID from appointment data
    final realPatientId = (app['patientId'] ?? app['PatientId'] ?? '').toString();
    final patientIdStr = realPatientId.isNotEmpty ? '#$realPatientId' : '#${name.split(' ').first.toUpperCase()}';
    final patientEmail = (app['patientEmail'] ?? app['PatientEmail'] ?? '').toString();
    final patientPhone = (app['patientPhone'] ?? app['PatientPhone'] ?? '').toString();
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientRecordDetailPage(
              patientName: name,
              patientId: patientIdStr,
              patientData: {
                'id': realPatientId.isNotEmpty ? realPatientId : patientIdStr,
                'firstName': name.split(' ').isNotEmpty ? name.split(' ').first : name,
                'lastName': name.split(' ').length > 1 ? name.split(' ').last : '',
                'email': patientEmail,
                'phone': patientPhone,
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5)),
          ],
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(time, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                      Text(period, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade400)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF0F172A))),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              details, 
                              style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade400),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _statusBadge(status),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'reschedule') {
                      _rescheduleAppointment(context, name);
                    } else if (value == 'delete') {
                      _deleteAppointment(context, name, time);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'reschedule', child: Row(children: [Icon(Icons.calendar_month, size: 18), SizedBox(width: 8), Text('Reschedule')])),
                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                  ],
                  child: Icon(Icons.more_vert, size: 20, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey.shade100),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientRecordDetailPage(
                            patientName: name,
                            patientId: patientIdStr,
                            patientData: {
                              'id': realPatientId.isNotEmpty ? realPatientId : patientIdStr,
                              'firstName': name.split(' ').isNotEmpty ? name.split(' ').first : name,
                              'lastName': name.split(' ').length > 1 ? name.split(' ').last : '',
                              'email': patientEmail,
                              'phone': patientPhone,
                            },
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007580),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('START CONSULTATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateAppointmentStatus(app, 'completed'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: status == 'completed' ? const Color(0xFF10B981) : Colors.transparent,
                      side: BorderSide(color: status == 'completed' ? const Color(0xFF10B981) : (isDark ? Colors.white24 : Colors.grey.shade300)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      'Completed',
                      style: TextStyle(
                        color: status == 'completed' ? Colors.white : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateAppointmentStatus(app, 'pending'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: status == 'pending' ? const Color(0xFFF59E0B) : Colors.transparent,
                      side: BorderSide(color: status == 'pending' ? const Color(0xFFF59E0B) : (isDark ? Colors.white24 : Colors.grey.shade300)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      'Pending',
                      style: TextStyle(
                        color: status == 'pending' ? Colors.white : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _availableSlotItem(String slot) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final parts = slot.split(' ');
    final time = parts[0];
    final period = parts.length > 1 ? parts[1] : 'AM';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200, style: BorderStyle.solid),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Text(time, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400)),
                Text(period, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isDark ? Colors.white12 : Colors.grey.shade300)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(width: 2, height: 28, color: isDark ? Colors.white10 : Colors.grey.shade100),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Slot',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C4D4).withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: 16, color: Color(0xFF00C4D4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _rescheduleAppointment(BuildContext context, String name) {
    healixStore.addNotification(
      'Action Required: Reschedule',
      'Dr. ${healixStore.userName.value} requested a reschedule for your appointment.',
      type: 'appointment_action',
      target: 'patient',
      metadata: {
        'doctorId': healixStore.doctorId.value,
        'doctorName': healixStore.userName.value,
      }
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reschedule request sent to patient.')));
  }

  void _deleteAppointment(BuildContext context, String name, String time) {
    healixStore.addNotification(
      'Action Required: Cancellation',
      'Dr. ${healixStore.userName.value} has requested to cancel your appointment at $time.',
      type: 'appointment_action',
      target: 'patient',
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cancellation request sent to patient.')));
  }

  void _updateAppointmentStatus(Map<String, dynamic> app, String status) async {
    // 1. Update status locally in _allAppointments
    setState(() {
      for (var a in _allAppointments) {
        if (a['id'] == app['id'] || 
            (a['patientName'] == app['patientName'] && a['appointmentDate'] == app['appointmentDate'])) {
          a['status'] = status;
        }
      }
    });

    // 2. Update status in healixStore
    final patientName = app['patientName'] ?? '';
    final appointmentDate = app['appointmentDate'] ?? '';
    await healixStore.updateDoctorAppointmentStatus(patientName, appointmentDate, status);

    // 3. Call backend API if ID is available
    final appointmentId = app['id'];
    if (appointmentId != null && status == 'completed') {
      try {
        await doctorService.completeAppointment(appointmentId);
      } catch (e) {
        debugPrint('Failed to mark appointment completed on backend: $e');
      }
    }
  }

  Widget _statusBadge(String status) {
    final isPending = status == 'pending';
    final isCompleted = status == 'completed';

    Color bgColor = const Color(0xFFBBEBF0);
    Color textColor = const Color(0xFF007580);
    IconData icon = Icons.check_circle;

    if (isPending) {
      bgColor = const Color(0xFFFAF3EC);
      textColor = const Color(0xFFB3672B);
      icon = Icons.watch_later;
    } else if (isCompleted) {
      bgColor = const Color(0xFFF1F5F9);
      textColor = Colors.blueGrey;
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pastItem(BuildContext context, String timeFull, String name, String details) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final patientIdStr = 'PT-${name.split(' ').first.toUpperCase()}-12345';
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientRecordDetailPage(
              patientName: name,
              patientId: patientIdStr,
              patientData: {
                'id': patientIdStr,
                'name': name,
                'email': '${name.toLowerCase().replaceAll(' ', '')}@example.com',
                'phone': '+1 (555) 019-2834',
                'age': '32',
                'gender': 'Male',
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: Colors.white10) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              child: Text(timeFull, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade500), textAlign: TextAlign.center),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.blueGrey.shade700)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(details, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade400)),
                      const SizedBox(width: 8),
                      _statusBadge('completed'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: isDark ? Colors.white30 : Colors.blueGrey.shade300, size: 20),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context, List<Map<String, dynamic>> notifs) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          child: notifs.isEmpty 
            ? const Text('No new notifications')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: notifs.length,
                itemBuilder: (context, index) {
                  final n = notifs[index];
                  final isAiResult = n['type'] == 'patient_ai_result';
                  return ListTile(
                    leading: Icon(
                      isAiResult ? Icons.auto_awesome : Icons.calendar_today,
                      color: const Color(0xFF00C4D4),
                    ),
                    title: Text(n['title'] ?? ''),
                    subtitle: Text(n['message'] ?? ''),
                    trailing: Text(n['time'] ?? '', style: const TextStyle(fontSize: 10)),
                    onTap: isAiResult ? () {
                      Navigator.pop(context);
                      final meta = n['metadata'] ?? {};
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientRecordDetailPage(
                            patientName: meta['patientName'] ?? 'Patient',
                            patientId: meta['patientId'] ?? meta['id'] ?? '#PT-12345',
                            patientData: meta,
                          ),
                        ),
                      );
                    } : null,
                  );
                },
              ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          TextButton(onPressed: () {
            healixStore.clearNotifications();
            Navigator.pop(context);
          }, child: const Text('Clear All')),
        ],
      ),
    );
  }

  Widget _buildAiInsightsCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [const Color(0xFF007580).withOpacity(0.15), const Color(0xFF0F172A)]
              : [const Color(0xFFE0FAFC), const Color(0xFFF1F9FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: const Color(0xFF00C4D4).withOpacity(0.3)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Color(0xFF00C4D4), shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 16),
          Text('Healix AI Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Text(
            'Based on today\'s schedule, you have a 30-minute gap between 10:15 and 11:30. Would you like to review Elena Rodriguez\'s updated pathology reports during this time?',
            style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade300 : Colors.blueGrey.shade700, height: 1.5),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007580),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Review Reports', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isDark ? Colors.white30 : Colors.blueGrey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text('Dismiss', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade500, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

