import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/doctor_service.dart';
import '../store/healix_store.dart';
import '../widgets/ai_analysis_detail.dart';

class PatientRecordDetailPage extends StatefulWidget {
  final String patientName;
  final String patientId;
  final Map<String, dynamic>? patientData;

  const PatientRecordDetailPage({
    super.key,
    required this.patientName,
    required this.patientId,
    this.patientData,
  });

  @override
  State<PatientRecordDetailPage> createState() => _PatientRecordDetailPageState();
}

class _PatientRecordDetailPageState extends State<PatientRecordDetailPage> {
  List<Map<String, dynamic>> _aiAnalyses = [];
  bool _loadingAi = true;
  int? _expandedAnalysisIndex;
  List<String> _observations = [
    'Stable vitals, continued medication.',
    'Lipid panel and metabolic results.'
  ];
  final TextEditingController _reportController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPersistedData();
    _loadAiAnalyses();
  }

  Future<void> _loadAiAnalyses() async {
    final patientId = widget.patientId.replaceAll('#', '').trim();
    if (patientId.isEmpty || patientId == 'N/A') {
      if (mounted) setState(() => _loadingAi = false);
      return;
    }

    final analyses = await doctorService.getPatientAiAnalyses(patientId);
    if (mounted) {
      setState(() {
        _aiAnalyses = analyses;
        _loadingAi = false;
      });
    }
  }

  Future<void> _loadPersistedData() async {
    final prefs = await SharedPreferences.getInstance();
    final String obsKey = 'obs_${widget.patientId}';
    final String reportKey = 'report_${widget.patientId}';

    final List<String>? savedObs = prefs.getStringList(obsKey);
    final String? savedReport = prefs.getString(reportKey);

    if (mounted) {
      setState(() {
        if (savedObs != null) _observations = savedObs;
        if (savedReport != null) _reportController.text = savedReport;
      });
    }
    
    _reportController.addListener(() {
      prefs.setString(reportKey, _reportController.text);
    });
  }

  Future<void> _saveObservations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('obs_${widget.patientId}', _observations);
  }

  void _addObservation() {
    showDialog(
      context: context,
      builder: (context) {
        String newObs = '';
        return AlertDialog(
          title: const Text('Add Observation'),
          content: TextField(
            onChanged: (value) => newObs = value,
            decoration: const InputDecoration(hintText: "Enter observation..."),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (newObs.isNotEmpty) {
                  setState(() => _observations.insert(0, newObs));
                  await _saveObservations();
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/images/logo_full.jpeg',
          height: 25,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, color: Color(0xFF007580)), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientHeader(isDark, cardColor, textColor, subTextColor),
            const SizedBox(height: 24),
            _buildSectionHeader('AI Analysis History', Icons.auto_awesome, textColor),
            const SizedBox(height: 8),
            Text(
              '${_aiAnalyses.length} saved ${_aiAnalyses.length == 1 ? 'analysis' : 'analyses'}',
              style: TextStyle(fontSize: 13, color: subTextColor),
            ),
            const SizedBox(height: 16),
            _buildAiHistorySection(isDark, cardColor, textColor, subTextColor),
            const SizedBox(height: 24),
            _buildSectionHeader('Doctor Report', Icons.description_outlined, textColor),
            const SizedBox(height: 16),
            _buildReportField(cardColor, textColor),
            const SizedBox(height: 24),
            _buildSectionHeader('Clinical Observations', Icons.history, textColor),
            const SizedBox(height: 16),
            _buildHistoryTimeline(isDark, cardColor, textColor, subTextColor),
            const SizedBox(height: 24),
            _buildSectionHeader('Latest Lab Results', Icons.science_outlined, textColor),
            const SizedBox(height: 16),
            _buildLabResultsList(cardColor, textColor, subTextColor),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  String _getGenderText(dynamic gender) {
    if (gender == null) return 'N/A';
    final g = gender.toString().toLowerCase();
    if (g == '1' || g == 'male') return 'Male';
    if (g == '2' || g == 'female') return 'Female';
    return gender.toString();
  }

  Widget _buildPatientHeader(bool isDark, Color cardColor, Color textColor, Color subTextColor) {
    final data = widget.patientData;
    final age = data?['age'] ?? data?['Age'];
    final gender = _getGenderText(data?['gender'] ?? data?['Gender']);
    final email = (data?['email'] ?? data?['Email'] ?? '').toString();
    final phone = (data?['phone'] ?? data?['Phone'] ?? '').toString();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: const Color(0xFF007580).withOpacity(0.1),
                child: Text(
                  widget.patientName.isNotEmpty ? widget.patientName.substring(0, 1).toUpperCase() : 'P',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF007580)),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.patientName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 2),
                    Text('ID: ${widget.patientId}', style: TextStyle(fontSize: 13, color: subTextColor)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (age != null) _infoBadge('Age: $age', Colors.blueGrey),
                        if (gender != 'N/A') _infoBadge(gender, gender == 'Male' ? Colors.blue : Colors.pink),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (email.isNotEmpty || phone.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey.shade100),
            const SizedBox(height: 12),
            if (email.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.email_outlined, size: 14, color: subTextColor),
                  const SizedBox(width: 8),
                  Flexible(child: Text(email, style: TextStyle(fontSize: 13, color: subTextColor), overflow: TextOverflow.ellipsis)),
                ],
              ),
            if (phone.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.phone_outlined, size: 14, color: subTextColor),
                  const SizedBox(width: 8),
                  Text(phone, style: TextStyle(fontSize: 13, color: subTextColor)),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _infoBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color textColor) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF007580), size: 20),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
      ],
    );
  }

  Widget _buildAiHistorySection(bool isDark, Color cardColor, Color textColor, Color subTextColor) {
    if (_loadingAi) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: Color(0xFF007580)),
        ),
      );
    }

    if (_aiAnalyses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.auto_awesome_outlined, size: 40, color: subTextColor),
            const SizedBox(height: 12),
            Text('No AI analyses yet', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 6),
            Text(
              'When this patient runs and saves an AI analysis, the full history will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: subTextColor, height: 1.4),
            ),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(_aiAnalyses.length, (index) {
        final analysis = _aiAnalyses[index];
        final disease = (analysis['disease'] ?? 'General').toString();
        final status = (analysis['statusLevel'] ?? analysis['riskLevel'] ?? 'healthy').toString();
        final statusColor = AiAnalysisDetail.statusColor(status);
        final score = AiAnalysisDetail.riskScore(analysis);
        final isExpanded = _expandedAnalysisIndex == index;
        final desc = (analysis['riskDescription'] ?? '').toString();
        final inputs = analysis['inputs'] as Map<String, dynamic>?;

        return Container(
          margin: EdgeInsets.only(bottom: index == _aiAnalyses.length - 1 ? 0 : 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: statusColor.withOpacity(0.25)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(() => _expandedAnalysisIndex = isExpanded ? null : index),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.auto_awesome, color: statusColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(disease, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
                            const SizedBox(height: 4),
                            Text(
                              AiAnalysisDetail.formatDate(analysis['timestamp'] ?? analysis['createdAt']),
                              style: TextStyle(fontSize: 12, color: subTextColor),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${score.toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: statusColor)),
                          Text(AiAnalysisDetail.statusLabel(status), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: subTextColor),
                    ],
                  ),
                ),
              ),
              if (isExpanded) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: score / 100,
                          minHeight: 8,
                          backgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        ),
                      ),
                      if (desc.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text('AI Reasoning', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                        const SizedBox(height: 6),
                        Text(desc, style: TextStyle(fontSize: 13, color: subTextColor, height: 1.5)),
                      ],
                      if (inputs != null && inputs.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text('Patient Inputs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: inputs.entries.map((e) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(e.key.toUpperCase(), style: TextStyle(fontSize: 9, color: subTextColor, fontWeight: FontWeight.bold)),
                                Text(e.value.toString(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
                              ],
                            ),
                          )).toList(),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => AiAnalysisDetail.showDetailSheet(context, analysis),
                          icon: const Icon(Icons.open_in_full, size: 16),
                          label: const Text('View Full Details'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF007580),
                            side: const BorderSide(color: Color(0xFF007580)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReportField(Color cardColor, Color textColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: _reportController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Enter your professional report...',
              border: InputBorder.none,
              hintStyle: TextStyle(fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              if (_reportController.text.isNotEmpty) {
                _sendReportToPatient();
              }
            },
            icon: const Icon(Icons.send, size: 18, color: Colors.white),
            label: const Text('SEND TO PATIENT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007580),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  void _sendReportToPatient() {
    final reportText = _reportController.text;
    final doctorName = healixStore.userName.value;
    
    // Save report to store
    healixStore.addPatientReport(widget.patientName, {
      'doctorName': doctorName,
      'content': reportText,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Notify patient
    healixStore.addNotification(
      'New Medical Report',
      'Dr. $doctorName has submitted a report for your review.',
      type: 'patient',
      target: 'patient',
      metadata: {
        'doctorName': doctorName,
        'content': reportText,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report sent to patient successfully!')),
    );
  }

  Widget _buildHistoryTimeline(bool isDark, Color cardColor, Color textColor, Color subTextColor) {
    return Column(
      children: List.generate(_observations.length, (index) {
        return _timelineItem(
          index == 0 ? 'Latest Visit' : 'Past Visit',
          'Oct ${12 - index}, 2023',
          _observations[index],
          index == _observations.length - 1,
          cardColor,
          textColor,
          subTextColor,
          index,
        );
      }),
    );
  }

  Widget _timelineItem(String title, String date, String desc, bool isLast, Color cardColor, Color textColor, Color subTextColor, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFF007580), shape: BoxShape.circle)),
            if (!isLast) Container(width: 2, height: 50, color: const Color(0xFF007580).withOpacity(0.2)),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                    onPressed: () async {
                      setState(() => _observations.removeAt(index));
                      await _saveObservations();
                    },
                  ),
                ],
              ),
              Text(date, style: TextStyle(fontSize: 12, color: subTextColor)),
              const SizedBox(height: 4),
              Text(desc, style: TextStyle(fontSize: 13, color: subTextColor)),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabResultsList(Color cardColor, Color textColor, Color subTextColor) {
    return Column(
      children: [
        _labResultItem('Glucose', '98 mg/dL', 'Normal', cardColor, textColor, subTextColor),
        const SizedBox(height: 12),
        _labResultItem('Cholesterol', '185 mg/dL', 'Normal', cardColor, textColor, subTextColor),
      ],
    );
  }

  Widget _labResultItem(String title, String value, String status, Color cardColor, Color textColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            Text(status, style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
          ]),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _addObservation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007580),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add Observation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F9FB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF007580).withOpacity(0.2)),
              ),
              child: const Icon(Icons.video_call_outlined, color: Color(0xFF007580)),
            ),
          ],
        ),
      ),
    );
  }
}

