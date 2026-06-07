import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Information Collection',
              'We collect information you provide directly to us, such as when you create an account, update your profile, or use our health tracking features. This may include your name, email address, health metrics, and medical history.',
              isDark,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Use of Information',
              'We use the information we collect to provide, maintain, and improve our services, to personalize your experience, and to provide you with insights into your health data using our AI analysis tools.',
              isDark,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Data Security',
              'We take the security of your health data very seriously. We implement industry-standard encryption and security measures to protect your information from unauthorized access, disclosure, or alteration.',
              isDark,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Your Rights',
              'You have the right to access, correct, or delete your personal information at any time through your profile settings. You can also request a copy of your data or withdraw your consent for certain data processing activities.',
              isDark,
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Last Updated: October 2023',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: isDark ? Colors.white70 : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
