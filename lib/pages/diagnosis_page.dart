import 'package:flutter/material.dart';
import '../widgets/healix_app_bar.dart';

class DiagnosisPage extends StatelessWidget {
  const DiagnosisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const HealixAppBar(),
      body: const Center(
        child: Text('Diagnosis Page - Coming Soon'),
      ),
    );
  }
}
