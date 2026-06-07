import 'package:flutter/material.dart';
import 'schedule_appointment_page.dart';
import '../utils/page_transitions.dart';
import '../widgets/healix_app_bar.dart';
import '../widgets/healix_background.dart';
import '../services/doctor_service.dart';
import '../store/healix_store.dart';

class DoctorsListPage extends StatefulWidget {
  const DoctorsListPage({super.key});

  @override
  State<DoctorsListPage> createState() => _DoctorsListPageState();
}

class _DoctorsListPageState extends State<DoctorsListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSpecialty = 'All';
  List<Map<String, dynamic>> _doctors = [];
  List<String> _specialties = ['All'];
  bool _isLoading = true;

  // Specialty icon map
  final Map<String, IconData> _specialtyIcons = {
    'Cardiology': Icons.favorite,
    'Neurology': Icons.psychology,
    'Dermatology': Icons.face,
    'Orthopedics': Icons.accessibility_new,
    'Pediatrics': Icons.child_care,
    'Ophthalmology': Icons.visibility,
    'Gynecology': Icons.pregnant_woman,
    'ENT': Icons.hearing,
    'Oncology': Icons.biotech,
    'Psychiatry': Icons.self_improvement,
    'General': Icons.medical_services,
    'All': Icons.grid_view_rounded,
  };

  // Specialty color map
  final Map<String, Color> _specialtyColors = {
    'Cardiology': const Color(0xFFFF6B6B),
    'Neurology': const Color(0xFF845EF7),
    'Dermatology': const Color(0xFFFF9F43),
    'Orthopedics': const Color(0xFF00C4D4),
    'Pediatrics': const Color(0xFF26de81),
    'Ophthalmology': const Color(0xFF4ECDC4),
    'Gynecology': const Color(0xFFFF78C1),
    'ENT': const Color(0xFF778CA3),
    'Oncology': const Color(0xFF0088CC),
    'Psychiatry': const Color(0xFF7ED6DF),
    'General': const Color(0xFF6C5CE7),
    'All': const Color(0xFF00AACD),
  };

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);
    final doctors = await doctorService.getDoctors();
    if (mounted) {
      // Build specialty list
      final specs = <String>{'All'};
      for (final doc in doctors) {
        final spec = (doc['specialization'] ?? '').toString().trim();
        if (spec.isNotEmpty) specs.add(spec);
      }
      setState(() {
        _doctors = doctors;
        _specialties = specs.toList();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredDoctors {
    return _doctors.where((doc) {
      final fullName = "${doc['firstName'] ?? ''} ${doc['lastName'] ?? ''}".toLowerCase();
      final spec = (doc['specialization'] ?? '').toString().toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          fullName.contains(_searchQuery.toLowerCase()) ||
          spec.contains(_searchQuery.toLowerCase());
      final matchesSpecialty = _selectedSpecialty == 'All' ||
          spec == _selectedSpecialty.toLowerCase();
      return matchesSearch && matchesSpecialty;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const HealixAppBar(),
      body: HealixBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF00AACD)))
            : RefreshIndicator(
                onRefresh: _loadDoctors,
                color: const Color(0xFF00AACD),
                child: CustomScrollView(
                  slivers: [
                    // ── Header ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Find Your Doctor',
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_doctors.length} verified specialists available',
                                        style: TextStyle(
                                          color: isDark ? Colors.white54 : const Color(0xFF64748B),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00AACD).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.tune_rounded, color: Color(0xFF00AACD)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // ── Search Bar ──
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (v) => setState(() => _searchQuery = v),
                                style: TextStyle(color: textColor),
                                decoration: InputDecoration(
                                  hintText: 'Search by name or specialty...',
                                  hintStyle: TextStyle(
                                    color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                                    fontSize: 14,
                                  ),
                                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00AACD)),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(Icons.clear, color: isDark ? Colors.white38 : Colors.grey),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() => _searchQuery = '');
                                          },
                                        )
                                      : null,
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ── Specialty Filter Chips ──
                            SizedBox(
                              height: 38,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _specialties.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, i) {
                                  final spec = _specialties[i];
                                  final isSelected = _selectedSpecialty == spec;
                                  final chipColor = _getSpecialtyColor(spec);
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedSpecialty = spec),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? chipColor
                                            : (isDark ? const Color(0xFF1E293B) : Colors.white),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected ? chipColor : (isDark ? Colors.white12 : Colors.grey.shade200),
                                        ),
                                        boxShadow: isSelected
                                            ? [BoxShadow(color: chipColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                                            : [],
                                      ),
                                      child: Text(
                                        spec,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ── Results count ──
                            Row(
                              children: [
                                Text(
                                  '${_filteredDoctors.length} doctor${_filteredDoctors.length != 1 ? 's' : ''} found',
                                  style: TextStyle(
                                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),

                    // ── Doctor Cards ──
                    if (_filteredDoctors.isEmpty)
                      SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 60),
                            child: Column(
                              children: [
                                Icon(Icons.search_off_rounded, size: 64, color: isDark ? Colors.white24 : Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  'No doctors found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try a different name or specialty',
                                  style: TextStyle(
                                    color: isDark ? Colors.white38 : Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final doc = _filteredDoctors[index];
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: Duration(milliseconds: 300 + (index * 80)),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) => Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: child,
                                  ),
                                ),
                                child: _buildDoctorCard(context, doc, isDark),
                              );
                            },
                            childCount: _filteredDoctors.length,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Color _getSpecialtyColor(String spec) {
    for (final key in _specialtyColors.keys) {
      if (spec.toLowerCase().contains(key.toLowerCase())) {
        return _specialtyColors[key]!;
      }
    }
    return const Color(0xFF00AACD);
  }

  IconData _getSpecialtyIcon(String spec) {
    for (final key in _specialtyIcons.keys) {
      if (spec.toLowerCase().contains(key.toLowerCase())) {
        return _specialtyIcons[key]!;
      }
    }
    return Icons.medical_services;
  }

  // Parse working days string like "Sunday-Thursday" into short labels
  List<String> _parseWorkingDays(String? workingDays) {
    if (workingDays == null || workingDays.isEmpty) {
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    }
    final Map<String, String> dayMap = {
      'sunday': 'Sun', 'monday': 'Mon', 'tuesday': 'Tue',
      'wednesday': 'Wed', 'thursday': 'Thu', 'friday': 'Fri', 'saturday': 'Sat',
    };
    final parts = workingDays.split('-');
    if (parts.length == 2) {
      final allDays = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
      final startIdx = allDays.indexOf(parts[0].toLowerCase().trim());
      final endIdx = allDays.indexOf(parts[1].toLowerCase().trim());
      if (startIdx != -1 && endIdx != -1 && startIdx <= endIdx) {
        return allDays.sublist(startIdx, endIdx + 1)
            .map((d) => dayMap[d] ?? d.substring(0, 3))
            .toList();
      }
    }
    return workingDays.split(',').map((d) => d.trim().substring(0, 3)).toList();
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return '';
    try {
      final parts = timeStr.split(':');
      int hour = int.parse(parts[0]);
      final min = parts[1].padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return '$hour:$min $period';
    } catch (_) {
      return timeStr;
    }
  }

  Widget _buildDoctorCard(BuildContext context, Map<String, dynamic> doc, bool isDark) {
    final firstName = doc['firstName'] ?? '';
    final lastName = doc['lastName'] ?? '';
    final fullName = "Dr. $firstName $lastName".trim();
    final spec = (doc['specialization'] ?? 'General Practitioner').toString();
    final specColor = _getSpecialtyColor(spec);
    final specIcon = _getSpecialtyIcon(spec);

    // Schedule info from doctor data
    final schedule = doc['doctorSchedule'] as Map<String, dynamic>?;
    final workingDays = _parseWorkingDays(schedule?['workingDays'] as String?);
    final startTime = _formatTime(schedule?['startTime'] as String?);
    final endTime = _formatTime(schedule?['endTime'] as String?);
    final isAvailable = schedule?['isAvailable'] ?? true;

    // Rating — use a fixed range since it's not in DB yet
    final docId = (doc['id'] ?? doc['personId'] ?? 0) as int;
    final rating = (4.5 + (docId % 5) * 0.1).toStringAsFixed(1);
    final reviews = 80 + (docId % 120);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Top section ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [specColor.withOpacity(0.8), specColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: specColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(specIcon, color: Colors.white, size: 28),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Doctor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              fullName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          // Availability badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? const Color(0xFF22C55E).withOpacity(0.12)
                                  : Colors.red.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isAvailable ? const Color(0xFF22C55E) : Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isAvailable ? 'Available' : 'Busy',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isAvailable ? const Color(0xFF22C55E) : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Specialty chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: specColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          spec,
                          style: TextStyle(
                            color: specColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Rating
                      Row(
                        children: [
                          ...List.generate(5, (i) => Icon(
                            i < double.parse(rating).floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: const Color(0xFFFFB800),
                            size: 14,
                          )),
                          const SizedBox(width: 6),
                          Text(
                            '$rating',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '($reviews reviews)',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white38 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ──
          Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey.shade100),

          // ── Schedule row ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Working days
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Days',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white38 : Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: workingDays.map((day) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: specColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: specColor.withOpacity(0.2)),
                          ),
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: specColor,
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ),

                // Time
                if (startTime.isNotEmpty && endTime.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Hours',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white38 : Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 12, color: isDark ? Colors.white54 : Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '$startTime – $endTime',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // ── Book + Subscribe Buttons ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ValueListenableBuilder<Map<String, dynamic>?>(
              valueListenable: healixStore.subscribedDoctor,
              builder: (context, subDoc, _) {
                final thisDocId = doc['id'] ?? doc['personId'] ?? 0;
                final subDocId = subDoc?['id'] ?? subDoc?['personId'];
                final isSubscribed = subDocId != null && subDocId == thisDocId;

                return Column(
                  children: [
                    // Book button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: isAvailable
                            ? () {
                                Navigator.push(
                                  context,
                                  SlideRightRoute(
                                    page: ScheduleAppointmentPage(
                                      doctorName: fullName,
                                      doctorId: thisDocId,
                                      specialty: spec,
                                      workingDays: workingDays,
                                      startTimeStr: startTime,
                                      endTimeStr: endTime,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAvailable ? specColor : Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        icon: const Icon(Icons.calendar_month_outlined, size: 18),
                        label: Text(
                          isAvailable ? 'Book Appointment' : 'Not Available',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subscribe button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: isSubscribed
                          ? OutlinedButton.icon(
                              onPressed: () async {
                                await healixStore.unsubscribeFromDoctor();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Unsubscribed from $fullName'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: specColor, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: Icon(Icons.notifications_active, size: 16, color: specColor),
                              label: Text(
                                'Unsubscribe',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: specColor),
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: () async {
                                await healixStore.subscribeToDoctor(doc);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Subscribed to $fullName! AI results will be shared with them.'),
                                      backgroundColor: const Color(0xFF007580),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F9FB),
                                foregroundColor: specColor,
                                elevation: 0,
                                side: BorderSide(color: specColor.withOpacity(0.3)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: Icon(Icons.notifications_outlined, size: 16, color: specColor),
                              label: Text(
                                'Subscribe',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: specColor),
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
