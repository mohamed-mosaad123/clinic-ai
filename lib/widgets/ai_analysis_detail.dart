import 'package:flutter/material.dart';

class AiAnalysisDetail {
  static Color statusColor(String? status) {
    switch (status) {
      case 'unhealthy':
        return const Color(0xFFEF4444);
      case 'risk':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF22C55E);
    }
  }

  static String statusLabel(String? status) {
    switch (status) {
      case 'unhealthy':
        return 'HIGH RISK';
      case 'risk':
        return 'MODERATE RISK';
      default:
        return 'LOW RISK';
    }
  }

  static String formatDate(dynamic value) {
    final dt = DateTime.tryParse(value?.toString() ?? '');
    if (dt == null) return 'Unknown date';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  static double riskScore(Map<String, dynamic> analysis) {
    return ((analysis['riskScore'] ?? analysis['probability'] ?? 0) as num).toDouble();
  }

  static void showDetailSheet(BuildContext context, Map<String, dynamic> analysis) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.blueGrey.shade400;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final disease = (analysis['disease'] ?? 'General').toString();
    final status = (analysis['statusLevel'] ?? analysis['riskLevel'] ?? 'healthy').toString();
    final color = statusColor(status);
    final score = riskScore(analysis);
    final desc = (analysis['riskDescription'] ?? '').toString();
    final inputs = analysis['inputs'] as Map<String, dynamic>?;
    final timestamp = analysis['timestamp'] ?? analysis['createdAt'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                          child: Icon(Icons.auto_awesome, color: color),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(disease, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                              Text(formatDate(timestamp), style: TextStyle(fontSize: 13, color: subTextColor)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                          child: Text(statusLabel(status), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [const Color(0xFF007580), color.withOpacity(0.8)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Risk Score', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                Text('${score.toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 72,
                            height: 72,
                            child: CircularProgressIndicator(
                              value: score / 100,
                              strokeWidth: 8,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (desc.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text('AI Diagnostic Reasoning', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
                      const SizedBox(height: 8),
                      Text(desc, style: TextStyle(fontSize: 14, color: subTextColor, height: 1.6)),
                    ],
                    if (inputs != null && inputs.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text('Patient Data Inputs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: inputs.entries.map((e) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(e.key.toUpperCase(), style: TextStyle(fontSize: 9, color: subTextColor, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(e.value.toString(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
                            ],
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007580),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
