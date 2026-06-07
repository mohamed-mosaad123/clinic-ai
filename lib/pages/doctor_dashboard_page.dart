import 'package:flutter/material.dart';
import 'patient_record_detail_page.dart';
import '../store/healix_store.dart';

import '../services/doctor_service.dart';

class DoctorDashboardPage extends StatefulWidget {
  final String username;
  final VoidCallback? onViewAllSchedule;
  const DoctorDashboardPage({super.key, this.username = 'Aris', this.onViewAllSchedule});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final dId = healixStore.doctorId.value;
    if (dId != null) {
      final apps = await doctorService.getAppointments(dId);
      if (mounted) {
        setState(() {
          _appointments = apps;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.blueGrey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.menu, color: Color(0xFF00C4D4)), onPressed: () {}),
        title: const Text('Healix', style: TextStyle(color: Color(0xFF00C4D4), fontWeight: FontWeight.bold, fontSize: 20)),
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
                    right: 12, 
                    top: 12, 
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                      child: Text(
                        unreadCount.toString(), 
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ),
              ]);
            }
          ),
          Container(
            margin: const EdgeInsets.only(right: 16, left: 8),
            child: const CircleAvatar(radius: 16, backgroundColor: Color(0xFF00C4D4), child: Text('DR', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _fetchData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('TODAY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF007580), letterSpacing: 1.0)),
                const SizedBox(height: 8),
                ValueListenableBuilder<String>(
                  valueListenable: healixStore.userName,
                  builder: (context, name, _) => Text('Welcome back, Dr. $name', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
                ),
                const SizedBox(height: 24),
                ValueListenableBuilder<Map<String, Map<String, dynamic>>>(
                  valueListenable: healixStore.patientAiResults,
                  builder: (context, aiResults, _) {
                    final urgentCount = aiResults.values.where((res) {
                      final status = res['statusLevel'] ?? 'healthy';
                      return status == 'unhealthy' || status == 'risk';
                    }).length;
                    return _buildBanner(isDark, urgentCount);
                  }
                ),
                const SizedBox(height: 24),
                ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: healixStore.doctorAppointments,
                  builder: (context, newApps, _) {
                    final combined = [...newApps, ..._appointments];
                    final today = DateTime.now();
                    bool isToday(String? dateStr) {
                      final d = DateTime.tryParse(dateStr ?? '');
                      if (d == null) return false;
                      return d.year == today.year && d.month == today.month && d.day == today.day;
                    }
                    final todayApps = combined.where((a) => isToday(a['appointmentDate'])).toList();
                    return _buildScheduleCard(isDark, cardColor, textColor, subTextColor, todayApps);
                  }
                ),
                const SizedBox(height: 24),
                _buildStatsRow(isDark),
                const SizedBox(height: 100),
              ]),
            ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF007580),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
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
                      Navigator.pop(context); // Close dialog
                      final meta = n['metadata'] ?? {};
                      final name = meta['patientName'] ?? 'Patient';
                      final id = meta['patientId'] ?? meta['id'] ?? '#PT-12345';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientRecordDetailPage(
                            patientName: name,
                            patientId: id,
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

  Widget _buildBanner(bool isDark, int urgentCount) {
    final hasUrgent = urgentCount > 0;
    final bannerColor = hasUrgent 
        ? (isDark ? const Color(0xFF7F1D1D).withOpacity(0.15) : const Color(0xFFFEF2F2))
        : (isDark ? const Color(0xFF007580).withOpacity(0.12) : const Color(0xFFF1F9FB));
    final borderColor = hasUrgent
        ? (isDark ? const Color(0xFFEF4444).withOpacity(0.3) : const Color(0xFFFEE2E2))
        : (isDark ? const Color(0xFF007580).withOpacity(0.3) : null);
    final iconColor = hasUrgent ? const Color(0xFFEF4444) : const Color(0xFF007580);
    final title = hasUrgent ? 'Urgent Action Required' : 'Clinical Assistant Active';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(16),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: iconColor.withOpacity(0.15), shape: BoxShape.circle),
          child: Icon(hasUrgent ? Icons.warning_amber_rounded : Icons.auto_awesome, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: iconColor)),
          const SizedBox(height: 4),
          RichText(text: TextSpan(style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade500, height: 1.4), children: hasUrgent ? [
            TextSpan(text: '$urgentCount critical analysis result${urgentCount > 1 ? "s" : ""}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const TextSpan(text: ' require your immediate clinical review.'),
          ] : const [
            TextSpan(text: 'All current patient AI health signals are stable and within normal ranges.'),
          ])),
        ])),
      ]),
    );
  }

  Widget _buildScheduleCard(bool isDark, Color cardColor, Color textColor, Color subTextColor, List<Map<String, dynamic>> apps) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            const Icon(Icons.calendar_today_outlined, color: Color(0xFF007580), size: 20),
            const SizedBox(width: 8),
            Text("Today's Schedule", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
          ]),
          GestureDetector(
            onTap: widget.onViewAllSchedule,
            child: const Text('View All', style: TextStyle(color: Color(0xFF007580), fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ]),
        const SizedBox(height: 20),
        if (apps.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('No appointments for today', style: TextStyle(color: Colors.grey)),
          )
        else
          ...apps.take(3).map((app) {
            final date = DateTime.tryParse(app['appointmentDate'] ?? '') ?? DateTime.now();
            final timeStr = "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
            final period = date.hour >= 12 ? 'PM' : 'AM';
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _scheduleItem(
                timeStr, 
                period, 
                app['patientName'] ?? 'Unknown Patient', 
                app['reason'] ?? 'Consultation', 
                false, 
                true, 
                isDark, 
                textColor, 
                subTextColor,
                appointmentData: app,
              ),
            );
          }).toList(),
      ]),
    );
  }

  Widget _scheduleItem(String time, String period, String name, String type, bool isHighlighted, bool showAction, bool isDark, Color textColor, Color subTextColor, {Map<String, dynamic> appointmentData = const {}}) {
    return Container(
      padding: isHighlighted ? const EdgeInsets.all(12) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: isHighlighted ? (isDark ? const Color(0xFF007580).withOpacity(0.1) : const Color(0xFFF1F9FB)) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Column(children: [
          Text(time, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isHighlighted ? textColor : const Color(0xFF007580))),
          Text(period, style: TextStyle(fontSize: 10, color: subTextColor, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(width: 16),
        Container(width: 2, height: 36, color: isHighlighted ? const Color(0xFF007580) : const Color(0xFFBBEBF0)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor)),
          const SizedBox(height: 2),
          Row(children: [
            Text(type, style: TextStyle(fontSize: 12, color: subTextColor)),
            if (isHighlighted) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF007580).withOpacity(0.2) : const Color(0xFFBBEBF0), borderRadius: BorderRadius.circular(4)),
                child: const Text('NEXT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF007580))),
              ),
            ]
          ]),
        ])),
        if (showAction)
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  final realPatientId = (appointmentData['patientId'] ?? appointmentData['PatientId'] ?? '').toString();
                  final patientIdStr = realPatientId.isNotEmpty ? '#$realPatientId' : '#${name.split(' ').first.toUpperCase()}';
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
                          'email': (appointmentData['patientEmail'] ?? appointmentData['PatientEmail'] ?? '').toString(),
                          'phone': (appointmentData['patientPhone'] ?? appointmentData['PatientPhone'] ?? '').toString(),
                        },
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007580), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), minimumSize: const Size(60, 32), padding: const EdgeInsets.symmetric(horizontal: 16)),
                child: const Text('START', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
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
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: isDark ? const Color(0xFF334155) : Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.more_vert, size: 20, color: isDark ? Colors.white70 : const Color(0xFF334155)),
                ),
              ),
            ],
          ),
      ]),
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

  Widget _buildStatsRow(bool isDark) {
    final today = DateTime.now();
    return Row(
      children: [
        // Daily Patients Card
        Expanded(
          child: ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: healixStore.doctorAppointments,
            builder: (context, storeApps, _) {
              // Count today's appointments from both backend list and store
              bool isToday(String? dateStr) {
                final d = DateTime.tryParse(dateStr ?? '');
                if (d == null) return false;
                return d.year == today.year && d.month == today.month && d.day == today.day;
              }
              final todayBackend = _appointments.where((a) => isToday(a['appointmentDate'])).length;
              final todayStore   = storeApps.where((a) => isToday(a['appointmentDate'])).length;
              final totalToday   = todayBackend + todayStore;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF007580).withOpacity(0.12) : const Color(0xFFF1F9FB),
                  borderRadius: BorderRadius.circular(16),
                  border: isDark ? Border.all(color: const Color(0xFF007580).withOpacity(0.3)) : null,
                ),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: isDark ? const Color(0xFF007580).withOpacity(0.2) : const Color(0xFFD0F0F4), shape: BoxShape.circle),
                    child: const Icon(Icons.people, color: Color(0xFF007580), size: 20),
                  ),
                  const SizedBox(height: 12),
                  Text('$totalToday', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF007580))),
                  const Text('DAILY PATIENTS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF0088CC), letterSpacing: 0.5)),
                ]),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        // Daily Reports Card
        Expanded(
          child: ValueListenableBuilder<Map<String, Map<String, dynamic>>>(
            valueListenable: healixStore.patientAiResults,
            builder: (context, aiResults, _) {
              return ValueListenableBuilder<Map<String, List<Map<String, dynamic>>>>(
                valueListenable: healixStore.patientReports,
                builder: (context, reports, _) {
                  final toCheck = aiResults.keys.where((pName) => reports[pName] == null || reports[pName]!.isEmpty).length;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF845EF7).withOpacity(0.12) : const Color(0xFFF3F0FF),
                      borderRadius: BorderRadius.circular(16),
                      border: isDark ? Border.all(color: const Color(0xFF845EF7).withOpacity(0.3)) : null,
                    ),
                    child: Column(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: isDark ? const Color(0xFF845EF7).withOpacity(0.2) : const Color(0xFFE5DBFF), shape: BoxShape.circle),
                        child: const Icon(Icons.analytics_outlined, color: Color(0xFF845EF7), size: 20),
                      ),
                      const SizedBox(height: 12),
                      Text('$toCheck', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF845EF7))),
                      const Text('REPORTS TO CHECK', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF845EF7), letterSpacing: 0.5)),
                    ]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color textColor) {
    return Row(children: [
      Icon(icon, color: const Color(0xFF007580), size: 20),
      const SizedBox(width: 8),
      Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
    ]);
  }

}
