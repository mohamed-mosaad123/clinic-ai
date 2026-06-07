import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/doctor_service.dart';
import '../store/healix_store.dart';
import '../widgets/ai_analysis_detail.dart';
import 'patient_record_detail_page.dart';

class DoctorAiResultPage extends StatefulWidget {
  const DoctorAiResultPage({super.key});

  @override
  State<DoctorAiResultPage> createState() => _DoctorAiResultPageState();
}

class _DoctorAiResultPageState extends State<DoctorAiResultPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _subscribedPatients = [];
  List<Map<String, dynamic>> _allAnalyses = [];
  bool _loadingSubs = true;
  bool _loadingAnalyses = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadSubscribedPatients(), _loadAnalyses()]);
  }

  Future<void> _loadAnalyses() async {
    final analyses = await doctorService.getAllAiAnalyses();
    if (mounted) {
      setState(() {
        _allAnalyses = analyses;
        _loadingAnalyses = false;
      });
    }
  }

  Future<void> _loadSubscribedPatients() async {
    final dId = healixStore.doctorId.value;
    if (dId != null) {
      final prefs = await SharedPreferences.getInstance();
      final subKey = 'subscribed_patients_$dId';
      final existingJson = prefs.getString(subKey);
      if (existingJson != null) {
        try {
          final list = jsonDecode(existingJson) as List<dynamic>;
          if (mounted) {
            setState(() {
              _subscribedPatients = list.map((item) => Map<String, dynamic>.from(item)).toList();
            });
          }
        } catch (_) {}
      }
    }
    if (mounted) {
      setState(() => _loadingSubs = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.blueGrey.shade400;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text('Patient AI Results', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00C4D4),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF00C4D4),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Subscribed Patients'),
            Tab(text: 'All Submissions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Tab 1: Patients who submitted AI results ──
          _buildSubscribedPatientsTab(isDark, cardColor, textColor, subTextColor),
          // ── Tab 2: Static sample submissions ──
          _buildAllSubmissionsTab(isDark, cardColor, textColor, subTextColor),
        ],
      ),
    );
  }

  Widget _buildSubscribedPatientsTab(bool isDark, Color cardColor, Color textColor, Color subTextColor) {
    if (_loadingAnalyses || _loadingSubs) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00C4D4)));
    }

    final subscribedAnalyses = _allAnalyses.where((analysis) {
      final patientId = (analysis['patientId'] ?? '').toString();
      final patientName = (analysis['patientName'] ?? '').toString();
      return _subscribedPatients.any((sub) {
        final subId = (sub['id'] ?? '').toString();
        final subName = (sub['name'] ?? '').toString().toLowerCase();
        return subId == patientId || subName == patientName.toLowerCase();
      });
    }).toList();

    if (subscribedAnalyses.isEmpty) {
      return _buildEmptyState(
        isDark, textColor, subTextColor,
        title: 'No Results Yet',
        message: 'When a subscribed patient runs an AI analysis and saves the result, it will appear here.',
        showInfo: true,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: subscribedAnalyses.length,
        itemBuilder: (context, index) => _buildAnalysisCard(
          context, subscribedAnalyses[index], isDark, cardColor, textColor, subTextColor,
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(
    BuildContext context,
    Map<String, dynamic> analysis,
    bool isDark, Color cardColor, Color textColor, Color subTextColor,
  ) {
    final patientName = (analysis['patientName'] ?? 'Unknown Patient').toString();
    final patientId = (analysis['patientId'] ?? '').toString();
    final disease = (analysis['disease'] ?? 'Unknown').toString();
    final statusLevel = (analysis['statusLevel'] ?? analysis['riskLevel'] ?? 'healthy').toString();
    final riskScore = AiAnalysisDetail.riskScore(analysis);
    final riskDescription = (analysis['riskDescription'] ?? '').toString();
    final statusColor = AiAnalysisDetail.statusColor(statusLevel);
    final timeStr = AiAnalysisDetail.formatDate(analysis['timestamp'] ?? analysis['createdAt']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.15),
                  child: Icon(Icons.person, color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patientName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                      Text(timeStr, style: TextStyle(fontSize: 12, color: subTextColor)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(AiAnalysisDetail.statusLabel(statusLevel), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Disease Model', style: TextStyle(fontSize: 11, color: subTextColor, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(disease, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                        ],
                      ),
                    ),
                    Text('${riskScore.toInt()}%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: statusColor)),
                  ],
                ),
                if (riskDescription.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(riskDescription, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: subTextColor, height: 1.4)),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => AiAnalysisDetail.showDetailSheet(context, analysis),
                        icon: const Icon(Icons.visibility_outlined, size: 16),
                        label: const Text('View Details'),
                        style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF007580)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PatientRecordDetailPage(
                                patientName: patientName,
                                patientId: patientId,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.history, size: 16, color: Colors.white),
                        label: const Text('Full History', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007580)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    bool isDark, Color textColor, Color subTextColor, {
    required String title,
    required String message,
    bool showInfo = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF00C4D4).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inbox_outlined, size: 48, color: Color(0xFF00C4D4)),
            ),
            const SizedBox(height: 20),
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: subTextColor, height: 1.5)),
            if (showInfo) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF007580).withOpacity(0.12) : const Color(0xFFF1F9FB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00C4D4).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF00C4D4), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Patients can subscribe to you in the Book Doctor page. Their AI results will appear here automatically.',
                        style: TextStyle(fontSize: 13, color: subTextColor, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Tab 2: All submissions ──
  Widget _buildAllSubmissionsTab(bool isDark, Color cardColor, Color textColor, Color subTextColor) {
    if (_loadingAnalyses) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00C4D4)));
    }

    if (_allAnalyses.isEmpty) {
      return _buildEmptyState(
        isDark, textColor, subTextColor,
        title: 'No Submissions Yet',
        message: 'When patients run an AI analysis and save their results, they will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: _allAnalyses.length,
        itemBuilder: (context, index) => _buildAnalysisCard(
          context, _allAnalyses[index], isDark, cardColor, textColor, subTextColor,
        ),
      ),
    );
  }
}
