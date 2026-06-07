import 'package:flutter/material.dart';

class UpdateEmailPage extends StatefulWidget {
  const UpdateEmailPage({super.key});

  @override
  State<UpdateEmailPage> createState() => _UpdateEmailPageState();
}

class _UpdateEmailPageState extends State<UpdateEmailPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.grey.shade400 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00AACD), size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Update Email',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            _buildEmailHeader(isDark, textColor, subTextColor),
            const SizedBox(height: 32),
            _emailField('CURRENT EMAIL', 'sarah.jenkins@healix.ai', enabled: false, isDark: isDark, cardColor: cardColor, subTextColor: subTextColor),
            const SizedBox(height: 16),
            _emailField('NEW EMAIL', 'Enter new email address', isDark: isDark, cardColor: cardColor, subTextColor: subTextColor),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Verification email sent!'),
                      backgroundColor: Color(0xFF0D9488),
                    ),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.send_outlined, size: 20),
                label: const Text('Update Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AACD),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSecurityInfoCard(isDark),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Back to account settings',
                style: TextStyle(color: Color(0xFF00AACD), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailHeader(bool isDark, Color textColor, Color subTextColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF00AACD).withOpacity(0.15) : const Color(0xFFE0F7FA),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_outlined, color: Color(0xFF00AACD), size: 40),
        ),
        const SizedBox(height: 24),
        Text(
          'Update Your Email',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 12),
        Text(
          'Your email will be used for important account security notifications and account recovery.',
          textAlign: TextAlign.center,
          style: TextStyle(color: subTextColor, fontSize: 15, height: 1.5),
        ),
      ],
    );
  }

  Widget _emailField(String label, String value, {bool enabled = true, required bool isDark, required Color cardColor, required Color subTextColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF006688), letterSpacing: 0.5),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: enabled ? cardColor : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: enabled ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: TextField(
            enabled: enabled,
            style: TextStyle(color: enabled ? (isDark ? Colors.white : const Color(0xFF334155)) : (isDark ? Colors.white38 : const Color(0xFF94A3B8))),
            decoration: InputDecoration(
              hintText: value,
              hintStyle: TextStyle(color: isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
              prefixIcon: Icon(Icons.mail_outline, color: subTextColor, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF00AACD).withOpacity(0.08) : const Color(0xFFF0FDFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF00AACD).withOpacity(0.2) : const Color(0xFFE0F7FA)),
      ),
      child: const Column(
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: Color(0xFF00AACD), size: 24),
              SizedBox(width: 16),
              Text(
                'Why email matters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF006688)),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'A verified email ensures you can always regain access to your account if you forget your password. We also use it to notify you about any unusual sign-in activity.',
            style: TextStyle(color: Color(0xFF006688), fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}
