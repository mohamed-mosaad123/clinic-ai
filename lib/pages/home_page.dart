import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'ai_agent_page.dart';
import 'profile_page.dart';
import 'history_page.dart';
import 'doctors_list_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, this.username = 'Alex'});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardPage(username: widget.username),
      const DoctorsListPage(),
      const AiAgentPage(),
      const HistoryPage(),
      const ProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
                _navItem(1, Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'Booking'),
                _middleNavItem(),
                _navItem(3, Icons.history_outlined, Icons.history_rounded, 'History'),
                _navItem(4, Icons.person_outline, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? const Color(0xFF00AACD) : const Color(0xFF64748B),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? const Color(0xFF00AACD) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _middleNavItem() {
    bool isSelected = _selectedIndex == 2;
    return GestureDetector(
      onTap: () => _onItemTapped(2),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00AACD) : const Color(0xFFF0FDFF),
          shape: BoxShape.circle,
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF00AACD).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Icon(
          Icons.auto_awesome,
          color: isSelected ? Colors.white : const Color(0xFF00AACD),
          size: 28,
        ),
      ),
    );
  }
}
