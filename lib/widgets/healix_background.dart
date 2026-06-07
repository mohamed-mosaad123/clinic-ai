import 'package:flutter/material.dart';

class HealixBackground extends StatelessWidget {
  final Widget child;
  const HealixBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        // Background Blobs
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00AACD).withOpacity(isDark ? 0.05 : 0.03),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00AACD).withOpacity(isDark ? 0.04 : 0.02),
            ),
          ),
        ),
        // Faint Medical Pattern (Pulse Line)
        Positioned(
          bottom: 50,
          right: 20,
          child: Opacity(
            opacity: isDark ? 0.05 : 0.03,
            child: Icon(
              Icons.show_chart, // Pulse-like icon
              size: 200,
              color: isDark ? Colors.white : const Color(0xFF00AACD),
            ),
          ),
        ),
        Positioned(
          top: 200,
          left: 40,
          child: Opacity(
            opacity: isDark ? 0.03 : 0.015,
            child: Icon(
              Icons.medical_services_outlined,
              size: 150,
              color: isDark ? Colors.white : const Color(0xFF00AACD),
            ),
          ),
        ),
        // The actual content
        child,
      ],
    );
  }
}
