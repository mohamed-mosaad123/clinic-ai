import 'package:flutter/material.dart';
import 'login_page.dart';
import '../store/healix_store.dart';
import '../services/auth_service.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  bool _urgentAlerts = true;
  bool _biometrics = true;
  String _labPrefs = 'End of Day';

  void _handleLogout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.grey.shade400 : Colors.blueGrey.shade400;
    final borderColor = isDark ? Colors.white10 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.menu, color: Color(0xFF00C4D4)), onPressed: () {}),
        title: Image.asset('assets/images/logo_full.jpeg', height: 32, fit: BoxFit.contain),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.redAccent.withOpacity(0.8)),
            onPressed: _handleLogout,
            tooltip: 'Log Out',
          ),
          IconButton(icon: Icon(Icons.notifications_none, color: isDark ? Colors.white70 : const Color(0xFF334155)), onPressed: () {}),
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFF00C4D4), shape: BoxShape.circle),
            child: const Text('DR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildStatusCards(),
            const SizedBox(height: 32),
            _buildSectionTitle(Icons.access_time_filled, 'Practice Hours'),
            const SizedBox(height: 16),
            _buildPracticeHours(),
            const SizedBox(height: 32),
            _buildSectionTitle(Icons.settings, 'Preferences'),
            const SizedBox(height: 16),
            _buildPreferences(),
            const SizedBox(height: 32),
            _buildSignOutButton(),
            const SizedBox(height: 80), // Padding for BottomNav
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    return ValueListenableBuilder<String>(
      valueListenable: healixStore.userName,
      builder: (context, name, _) {
        final email = authService.currentUser?.email ?? '';
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: isDark ? Border.all(color: Colors.white10) : null),
          child: Row(children: [
            Stack(children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C4D4).withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00C4D4), width: 2),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'D',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF00C4D4)),
                  ),
                ),
              ),
              Positioned(bottom: 0, right: 0, child: Container(width: 16, height: 16, decoration: BoxDecoration(color: const Color(0xFF10B981), shape: BoxShape.circle, border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.white, width: 2)))),
            ]),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Dr. $name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
              const SizedBox(height: 4),
              if (email.isNotEmpty)
                Text(email, style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 12)),
              Text('Chief Physician • Healix Medical', style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13, height: 1.4)),
            ])),
          ]),
        );
      },
    );
  }

  Widget _buildStatusCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00C4D4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.security, color: Colors.white, size: 20),
                const SizedBox(height: 12),
                const Text('Security Status', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Biometrics\nActive', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.2)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Builder(builder: (ctx) {
            final isDark2 = Theme.of(ctx).brightness == Brightness.dark;
            final cardColor2 = isDark2 ? const Color(0xFF1E293B) : Colors.white;
            final textColor2 = isDark2 ? Colors.white : const Color(0xFF0F172A);
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardColor2, borderRadius: BorderRadius.circular(16), border: isDark2 ? Border.all(color: Colors.white10) : null),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.science, color: Color(0xFF92400E), size: 20),
                const SizedBox(height: 12),
                Text('Lab Reports', style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Daily\nSummary', style: TextStyle(color: textColor2, fontSize: 16, fontWeight: FontWeight.bold, height: 1.2)),
              ]),
            );
          })
        ),
      ],
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    final textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF0F172A);
    return Row(children: [
      Icon(icon, color: textColor, size: 20),
      const SizedBox(width: 8),
      Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
    ]);
  }

  Widget _buildPracticeHours() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    return Container(
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: isDark ? Border.all(color: Colors.white10) : null),
      child: Column(children: [
        _buildHourRow('Monday — Friday', '08:00 AM - 05:00 PM'),
        Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey.shade100),
        _buildHourRow('Saturday', '09:00 AM - 01:00 PM'),
      ]),
    );
  }

  Widget _buildHourRow(String day, String time) {
    final textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF0F172A);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(day, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(time, style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 12)),
        ]),
        Icon(Icons.chevron_right, color: Colors.blueGrey.shade300, size: 20),
      ]),
    );
  }

  Widget _buildPreferences() {
    return Column(
      children: [
        _buildTogglePref(
          Icons.notifications_active,
          const Color(0xFFE0FAFC),
          const Color(0xFF007580),
          'Urgent Patient Alerts',
          'Override Silent Mode',
          _urgentAlerts,
          (val) => setState(() => _urgentAlerts = val),
        ),
        const SizedBox(height: 12),
        _buildTogglePref(
          Icons.fingerprint,
          const Color(0xFFE0FAFC),
          const Color(0xFF00C4D4),
          'FaceID / Biometrics',
          'Required for sensitive records',
          _biometrics,
          (val) => setState(() => _biometrics = val),
        ),
        const SizedBox(height: 12),
        Builder(builder: (ctx) {
          final isDark3 = Theme.of(ctx).brightness == Brightness.dark;
          return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark3 ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isDark3 ? Border.all(color: Colors.white10) : null,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Color(0xFFFFEDD5), shape: BoxShape.circle),
                    child: const Icon(Icons.description, color: Color(0xFF92400E), size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lab Report Prefs', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text('Automated delivery settings', style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _labPrefs = 'Real-time'),
                      child: Builder(builder: (ctx) {
                        final isDk = Theme.of(ctx).brightness == Brightness.dark;
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _labPrefs == 'Real-time' ? const Color(0xFF00C4D4) : (isDk ? Colors.white.withOpacity(0.08) : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Real-time',
                              style: TextStyle(
                                color: _labPrefs == 'Real-time' ? Colors.white : (isDk ? Colors.white70 : const Color(0xFF334155)),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _labPrefs = 'End of Day'),
                      child: Builder(builder: (ctx) {
                        final isDk = Theme.of(ctx).brightness == Brightness.dark;
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _labPrefs == 'End of Day' ? const Color(0xFF00C4D4) : (isDk ? Colors.white.withOpacity(0.08) : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'End of Day',
                              style: TextStyle(
                                color: _labPrefs == 'End of Day' ? Colors.white : (isDk ? Colors.white70 : const Color(0xFF334155)),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
        }),
      ],
    );
  }

  Widget _buildTogglePref(IconData icon, Color bgCol, Color iconCol, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: isDark ? Border.all(color: Colors.white10) : null),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: bgCol, shape: BoxShape.circle), child: Icon(icon, color: iconCol, size: 20)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 12)),
        ])),
        Switch(value: value, onChanged: onChanged, activeColor: Colors.white, activeTrackColor: const Color(0xFF00C4D4), inactiveThumbColor: Colors.white, inactiveTrackColor: Colors.grey.shade300),
      ]),
    );
  }

  Widget _buildSignOutButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _handleLogout,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Color(0xFFB91C1C), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: isDark ? const Color(0xFFB91C1C).withOpacity(0.08) : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout, color: Color(0xFFB91C1C), size: 20),
            SizedBox(width: 10),
            Text('Sign Out', style: TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
