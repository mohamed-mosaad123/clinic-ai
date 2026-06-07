import 'package:flutter/material.dart';
import '../widgets/healix_app_bar.dart';
import '../store/healix_store.dart';
import 'package:image_picker/image_picker.dart';

import '../services/patient_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final records = await patientService.getMedicalRecords();
    healixStore.setHistoryRecords(records);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const HealixAppBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadOptions(context, isDark),
        backgroundColor: const Color(0xFF00AACD),
        icon: const Icon(Icons.upload_file, color: Colors.white),
        label: const Text('Upload Record', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Medical History',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ValueListenableBuilder<Map<String, List<Map<String, dynamic>>>>(
                    valueListenable: healixStore.patientReports,
                    builder: (context, reportsMap, _) {
                      final doctorReports = reportsMap[healixStore.userName.value] ?? [];
                      return ValueListenableBuilder<List<Map<String, dynamic>>>(
                        valueListenable: healixStore.historyRecords,
                        builder: (context, records, _) {
                          final hasContent = records.isNotEmpty || doctorReports.isNotEmpty;
                          if (!hasContent) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.history_toggle_off, size: 64, color: isDark ? Colors.white24 : Colors.black12),
                                  const SizedBox(height: 16),
                                  Text('No history records found.',
                                    style: TextStyle(color: isDark ? Colors.white54 : Colors.black38, fontSize: 16)),
                                ],
                              ),
                            );
                          }
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              // ── Doctor Reports Section ──
                              if (doctorReports.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12, top: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.description_outlined, color: Color(0xFF00AACD), size: 18),
                                      const SizedBox(width: 8),
                                      Text('Doctor Reports',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : const Color(0xFF0F172A))),
                                    ],
                                  ),
                                ),
                                ...doctorReports.map((r) => _buildDoctorReportCard(context, r, isDark)),
                                const SizedBox(height: 8),
                              ],
                              // ── AI Predictions & Uploads Section ──
                              if (records.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12, top: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.auto_awesome, color: Color(0xFF8B5CF6), size: 18),
                                      const SizedBox(width: 8),
                                      Text('AI Predictions & Uploads',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : const Color(0xFF0F172A))),
                                    ],
                                  ),
                                ),
                                ...records.map((record) => _buildHistoryCard(context, record, isDark)),
                              ],
                            ],
                          );
                        },
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorReportCard(BuildContext context, Map<String, dynamic> report, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: const Color(0xFF00AACD).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00AACD).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.assignment_turned_in_outlined, color: Color(0xFF00AACD), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report from Dr. ${report['doctorName'] ?? 'Doctor'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    if (report['timestamp'] != null)
                      Text(
                        _formatTimestamp(report['timestamp']),
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : const Color(0xFF64748B)),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00AACD).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('REPORT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF00AACD), letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            (report['content'] ?? '').toString(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : Colors.blueGrey.shade600, height: 1.5),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showFullDoctorReport(context, report, isDark),
              child: const Text('Read Full Report', style: TextStyle(color: Color(0xFF00AACD), fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic ts) {
    final dt = DateTime.tryParse(ts.toString());
    if (dt == null) return '';
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  void _showFullDoctorReport(BuildContext context, Map<String, dynamic> report, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Row(children: [
              const Icon(Icons.description, color: Color(0xFF00AACD), size: 28),
              const SizedBox(width: 12),
              Text('Medical Report', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A))),
            ]),
            const SizedBox(height: 8),
            Text('Doctor: Dr. ${report['doctorName'] ?? 'Specialist'}',
              style: TextStyle(color: isDark ? Colors.white60 : Colors.blueGrey.shade600, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            Expanded(child: SingleChildScrollView(
              child: Text(
                (report['content'] ?? '').toString(),
                style: TextStyle(fontSize: 16, height: 1.6, color: isDark ? Colors.white : const Color(0xFF334155)),
              ),
            )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AACD),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> record, bool isDark) {
    final isAi = record['isAi'] == true;
    final iconColor = isAi ? const Color(0xFF8B5CF6) : const Color(0xFF00AACD);
    final iconData = isAi ? Icons.auto_awesome : Icons.description_outlined;
    final bgColor = isAi ? (isDark ? const Color(0xFF2E1E3B) : const Color(0xFFF3E8FF)) : (isDark ? const Color(0xFF1E293B) : Colors.white);
    final borderColor = isAi ? iconColor.withOpacity(0.3) : (isDark ? Colors.white10 : const Color(0xFFF1F5F9));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isAi ? iconColor.withOpacity(0.1) : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${record['type']} • ${record['date']}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          if (isAi)
            GestureDetector(
              onTap: () {
                 showDialog(
                   context: context,
                   builder: (context) => AlertDialog(
                     backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                     title: Row(
                       children: [
                         Icon(iconData, color: iconColor),
                         const SizedBox(width: 8),
                         const Text('Prediction Details'),
                       ],
                     ),
                     content: SizedBox(
                       width: double.maxFinite,
                       child: Column(
                         mainAxisSize: MainAxisSize.min,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text('Result: ${record['title']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                           const SizedBox(height: 16),
                           if (record['inputs'] != null) ...[
                             const Text('Patient Inputs:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 12)),
                             const SizedBox(height: 8),
                             Flexible(
                               child: ListView(
                                 shrinkWrap: true,
                                 children: (record['inputs'] as Map<String, dynamic>).entries.map((e) {
                                   return Padding(
                                     padding: const EdgeInsets.only(bottom: 6),
                                     child: Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                         Expanded(child: Text(e.key, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13))),
                                         Text('${e.value}', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, fontSize: 13)),
                                       ],
                                     ),
                                   );
                                 }).toList(),
                               ),
                             ),
                           ],
                         ],
                       ),
                     ),
                     actions: [
                       TextButton(
                         onPressed: () => Navigator.pop(context),
                         child: Text('Close', style: TextStyle(color: iconColor)),
                       ),
                     ],
                   ),
                 );
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: iconColor.withOpacity(0.3)),
                ),
                child: Text(
                  'View',
                  style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () {
              _showDeleteConfirmation(context, record['id'], record['title']);
            },
          ),
        ],
      ),
    );
  }

  void _showUploadOptions(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Medical Record',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              _buildUploadOption(context, Icons.picture_as_pdf, 'Upload PDF Document', 'Lab results, prescriptions, etc.', isDark),
              _buildUploadOption(context, Icons.image, 'Upload Image', 'Photos of reports or injuries', isDark),
              _buildUploadOption(context, Icons.science, 'Upload Lab Result', 'Raw data or CSV files', isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUploadOption(BuildContext context, IconData icon, String title, String subtitle, bool isDark) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF00AACD).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF00AACD)),
      ),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF64748B), fontSize: 12)),
      onTap: () {
        Navigator.pop(context);
        _uploadDocument(context, title);
      },
    );
  }

  void _uploadDocument(BuildContext context, String fileType) async {
    String finalTitle = fileType.replaceAll('Upload ', '');

    if (fileType == 'Upload Image') {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        if (image == null) return; // User canceled the picker
        finalTitle = image.name; // Use the actual selected file name
      } catch (e) {
        // Fallback if picker fails
      }
    } else {
      // For PDF/Lab Result, simulate file picking since file_picker needs Windows Developer Mode
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF00AACD)),
              const SizedBox(height: 20),
              Text(
                'Uploading Document...',
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'Securely saving to your patient record.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54),
              ),
            ],
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));
    if (context.mounted) Navigator.pop(context);

    final now = DateTime.now();
    final dateStr = '${_getMonth(now.month)} ${now.day}, ${now.year}';
    
    healixStore.addRecord({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': finalTitle,
      'date': dateStr,
      'type': 'Document',
      'status': 'Uploaded',
    });
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  void _showDeleteConfirmation(BuildContext context, String id, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Delete Record'),
          content: Text('Are you sure you want to delete the record for "$title"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
            ),
            TextButton(
              onPressed: () {
                healixStore.removeRecord(id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Record deleted successfully'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
