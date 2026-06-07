import 'package:flutter/material.dart';
import '../widgets/healix_app_bar.dart';
import 'doctors_list_page.dart';
import 'ai_agent_page.dart';
import 'history_page.dart';
import '../store/healix_store.dart';
import '../utils/page_transitions.dart';
import '../widgets/healix_background.dart';

import '../services/patient_service.dart';
import '../services/auth_service.dart';

class DashboardPage extends StatefulWidget {
  final String username;
  const DashboardPage({super.key, this.username = 'User'});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = true;

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    final pId = healixStore.patientId.value;
    if (pId != null) {
      final appointments = await patientService.getAppointments(pId);
      if (appointments.isNotEmpty) {
        final last = appointments.first;
        healixStore.setAppointment(
          last['doctorName'] ?? 'Doctor',
          last['appointmentDate']?.toString().split('T').first ?? 'TBD',
          last['appointmentDate']?.toString().split('T').last.substring(0, 5) ?? 'TBD',
        );
      }
      
      final records = await patientService.getMedicalRecords();
      healixStore.setHistoryRecords(records);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const HealixAppBar(),
      body: HealixBackground(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: RefreshIndicator(
                onRefresh: _fetchDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder<String>(
                        valueListenable: healixStore.userName,
                        builder: (context, name, _) => _buildWelcomeSection(name),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Upcoming Appointment', 'View All', isDark, () {
                        Navigator.push(context, SlideRightRoute(page: const DoctorsListPage()));
                      }),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<Map<String, dynamic>?>(
                      valueListenable: healixStore.lastAppointment,
                      builder: (context, appointment, child) {
                        if (appointment != null) {
                          return _buildUpcomingAppointment(context, 
                            doctorName: appointment['doctorName'],
                            date: appointment['date'],
                            time: appointment['time'],
                          );
                        }
                        return _buildNoAppointment(context);
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Recent Analysis', 'Full History', isDark, () {
                      Navigator.push(context, SlideRightRoute(page: const HistoryPage()));
                    }),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<Map<String, Map<String, dynamic>>>(
                      valueListenable: healixStore.patientAiResults,
                      builder: (context, aiResults, _) {
                        final currentUserName = healixStore.userName.value;
                        final currentPatientId = healixStore.patientId.value;
                        // Look up by patientId first, then by name
                        final latestAi = (currentPatientId != null ? aiResults[currentPatientId] : null)
                            ?? aiResults[currentUserName];
                        
                        return ValueListenableBuilder<List<Map<String, dynamic>>>(
                          valueListenable: healixStore.historyRecords,
                          builder: (context, records, _) {
                            if (latestAi != null) {
                              return _buildAiAnalysisCard(context, latestAi);
                            }
                            if (records.isNotEmpty) {
                              return _buildRecentAnalysis(context, record: records.first);
                            }
                            return const Center(child: Text('No recent analysis'));
                          },
                        );
                      },
                    ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Medical Reports', 'View All', isDark, () {
                        Navigator.push(context, SlideRightRoute(page: const HistoryPage()));
                      }),
                      const SizedBox(height: 12),
                      ValueListenableBuilder<Map<String, List<Map<String, dynamic>>>>(
                        valueListenable: healixStore.patientReports,
                        builder: (context, reportsMap, _) {
                          final reports = reportsMap[healixStore.userName.value] ?? [];
                          if (reports.isEmpty) {
                            return _buildNoReportsCard();
                          }
                          return Column(
                            children: reports.map((r) => _buildReportCard(context, r)).toList(),
                          );
                        }
                      ),
                      const SizedBox(height: 24),
                      _buildHealthPulseBanner(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildNoReportsCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: Column(children: [
        Icon(Icons.description_outlined, size: 32, color: isDark ? Colors.white24 : const Color(0xFF94A3B8)),
        const SizedBox(height: 8),
        Text('No medical reports yet', style: TextStyle(color: isDark ? Colors.white38 : const Color(0xFF64748B), fontSize: 13)),
      ]),
    );
  }

  Widget _buildReportCard(BuildContext context, Map<String, dynamic> report) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: isDark ? const Color(0xFF00AACD).withOpacity(0.15) : const Color(0xFFF0FDFF), shape: BoxShape.circle),
                child: const Icon(Icons.assignment_turned_in_outlined, color: Color(0xFF00AACD), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Report from Dr. ${report['doctorName']}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            report['content'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showFullReport(context, report),
              child: const Text('Read Full Report', style: TextStyle(color: Color(0xFF00AACD), fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullReport(BuildContext context, Map<String, dynamic> report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Row(children: [
              const Icon(Icons.description, color: Color(0xFF00AACD), size: 28),
              const SizedBox(width: 12),
              const Text('Medical Report', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 8),
            Text('Doctor: Dr. ${report['doctorName']}', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            Expanded(child: SingleChildScrollView(child: Text(report['content'], style: const TextStyle(fontSize: 16, height: 1.6)))),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAppointment(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(Icons.calendar_today_outlined, size: 48, color: isDark ? Colors.white24 : const Color(0xFF94A3B8)),
          const SizedBox(height: 16),
          Text(
            'No upcoming appointments',
            style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white54 : const Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.push(context, SlideRightRoute(page: const DoctorsListPage())),
            child: const Text('Book Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionText, bool isDark, VoidCallback onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          child: Text(
            actionText,
            style: const TextStyle(color: Color(0xFF00AACD), fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(String name) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_getTimeGreeting()}, $name 👋',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Here is your health overview for today.',
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingAppointment(BuildContext context, {String? doctorName, String? date, String? time}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0088CC).withOpacity(0.2) : const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_box_outlined, color: Color(0xFF0088CC), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName ?? 'Dr. Sarah Chen',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Consultation',
                      style: TextStyle(color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B), fontSize: 14),
                    ),
                  ],
                ),
              ),
              Icon(Icons.calendar_month_outlined, color: const Color(0xFF64748B).withOpacity(0.2), size: 64),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildAppointmentInfo(Icons.calendar_today_outlined, date ?? 'TBD', isDark),
              const SizedBox(width: 20),
              _buildAppointmentInfo(Icons.access_time, time ?? 'TBD', isDark),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Check-in successful! Please wait to be called.'),
                      ],
                    ),
                    backgroundColor: const Color(0xFF00AACD),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006677),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text('Check In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentInfo(IconData icon, String text, [bool isDark = false]) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0088CC), size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildAiAnalysisCard(BuildContext context, Map<String, dynamic> ai) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = ai['statusLevel'] ?? 'healthy';
    final disease = ai['disease'] ?? 'General';
    final riskScore = ((ai['riskScore'] ?? 0.0) as num).toDouble();
    final timestamp = DateTime.tryParse(ai['timestamp'] ?? '') ?? DateTime.now();
    final dateStr = "${timestamp.day}/${timestamp.month}";

    Color statusColor = const Color(0xFF10B981); // Healthy
    if (status == 'unhealthy') statusColor = const Color(0xFFEF4444);
    if (status == 'risk') statusColor = const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.auto_awesome, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('AI $disease Analysis', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(dateStr, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Status: ${status.toUpperCase()}', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (riskScore / 100).clamp(0.0, 1.0),
              child: Container(decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(4))),
            ),
          ),
          const SizedBox(height: 8),
          Text(ai['riskDescription'] ?? 'Analysis complete.', style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildRecentAnalysis(BuildContext context, {Map<String, dynamic>? record}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3F1F1F) : const Color(0xFFFDF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.water_drop_outlined, color: Color(0xFFB91C1C), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          record?['title'] ?? 'Blood Glucose Analysis',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(record?['date'] ?? 'Oct 12', style: TextStyle(color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B).withOpacity(0.6), fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1B3D2F) : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline, color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF166534), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'PROCESSED',
                            style: TextStyle(color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF166534), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: const Border(left: BorderSide(color: Color(0xFF0088CC), width: 4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.smart_toy_outlined, color: Color(0xFF0088CC), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Healix AI Summary',
                      style: TextStyle(color: Color(0xFF0088CC), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '\"Your latest blood glucose levels are within the optimal range. No significant fluctuations detected. Dr. Chen will discuss the full report during your appointment.\"',
                  style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF0F172A).withOpacity(0.8), fontSize: 14, fontStyle: FontStyle.italic, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AiAgentPage()));
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View Details',
                    style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF0F172A).withOpacity(0.7), fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, color: isDark ? Colors.white70 : const Color(0xFF0F172A).withOpacity(0.7), size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthPulseBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0088CC), Color(0xFF006688)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Healix Health Pulse',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your vitals are looking optimal today.',
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15),
              ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Icon(Icons.bar_chart, color: Colors.white.withOpacity(0.2), size: 60),
          ),
        ],
      ),
    );
  }
}
