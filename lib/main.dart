import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'services/auth_service.dart';
import 'store/healix_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/providers/auth_provider.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await healixStore.loadPersistedData();

  // Always clear stored session so the app starts on the Sign In page
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token');
  await prefs.remove('auth_user');

  runApp(
    const ProviderScope(
      child: HealixApp(),
    ),
  );
}

class HealixApp extends ConsumerWidget {
  const HealixApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Healix Patient Portal',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF00AACD),
              primary: const Color(0xFF00AACD),
              surface: Colors.white,
            ),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            fontFamily: 'Inter',
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color(0xFF00AACD),
              primary: const Color(0xFF00AACD),
              surface: const Color(0xFF1E293B),
              background: const Color(0xFF0F172A),
            ),
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            fontFamily: 'Inter',
          ),
          home: const LoginPage(),
        );
      },
    );
  }
}
