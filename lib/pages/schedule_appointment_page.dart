import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../store/healix_store.dart';
import '../services/patient_service.dart';

class ScheduleAppointmentPage extends StatefulWidget {
  final String doctorName;
  final int doctorId;
  final String specialty;
  final List<String> workingDays;
  final String startTimeStr;
  final String endTimeStr;

  const ScheduleAppointmentPage({
    super.key,
    this.doctorName = 'Dr. Julian Thorne',
    required this.doctorId,
    this.specialty = 'General Practitioner',
    this.workingDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    this.startTimeStr = '9:00 AM',
    this.endTimeStr = '5:00 PM',
  });

  @override
  State<ScheduleAppointmentPage> createState() => _ScheduleAppointmentPageState();
}

class _ScheduleAppointmentPageState extends State<ScheduleAppointmentPage> {
  DateTime _selectedDay = DateTime.now().add(const Duration(days: 1));
  DateTime _focusedMonth = DateTime.now();
  String _selectedTimeSlot = '';

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  Color get bgColor => isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  Color get cardColor => isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get textColor => isDark ? Colors.white : const Color(0xFF0F172A);
  Color get subTextColor => isDark ? Colors.grey.shade400 : Colors.grey.shade600;
  Color get borderColor => isDark ? Colors.white10 : Colors.grey.shade200;

  // Generate 30-min slots from start to end time
  List<String> _generateSlots(String startStr, String endStr) {
    try {
      TimeOfDay start = _parseTimeOfDay(startStr);
      TimeOfDay end = _parseTimeOfDay(endStr);
      final slots = <String>[];
      int current = start.hour * 60 + start.minute;
      final endMin = end.hour * 60 + end.minute;
      while (current + 30 <= endMin) {
        final h = current ~/ 60;
        final m = current % 60;
        final period = h >= 12 ? 'PM' : 'AM';
        final displayH = h > 12 ? h - 12 : (h == 0 ? 12 : h);
        slots.add('$displayH:${m.toString().padLeft(2, '0')} $period');
        current += 30;
      }
      return slots;
    } catch (_) {
      return ['09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM',
              '01:00 PM', '01:30 PM', '02:00 PM', '02:30 PM', '03:00 PM'];
    }
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    final cleaned = timeStr.trim();
    final parts = cleaned.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
    if (parts.length > 1) {
      if (parts[1].toUpperCase() == 'PM' && hour != 12) hour += 12;
      if (parts[1].toUpperCase() == 'AM' && hour == 12) hour = 0;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  List<String> get _allSlots => _generateSlots(widget.startTimeStr, widget.endTimeStr);

  List<String> get _morningSlots => _allSlots.where((s) {
    final t = _parseTimeOfDay(s);
    return t.hour < 12;
  }).toList();

  List<String> get _afternoonSlots => _allSlots.where((s) {
    final t = _parseTimeOfDay(s);
    return t.hour >= 12 && t.hour < 17;
  }).toList();

  List<String> get _eveningSlots => _allSlots.where((s) {
    final t = _parseTimeOfDay(s);
    return t.hour >= 17;
  }).toList();

  @override
  void initState() {
    super.initState();
    // Pre-select first available slot
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final all = _allSlots;
      if (all.isNotEmpty && _selectedTimeSlot.isEmpty) {
        setState(() => _selectedTimeSlot = all.first);
      }
    });
  }

  // Map short day names to weekday numbers (Mon=1, Sun=7)
  bool _isDoctorWorkingDay(DateTime date) {
    final Map<String, int> dayToWeekday = {
      'Mon': 1, 'Tue': 2, 'Wed': 3, 'Thu': 4, 'Fri': 5, 'Sat': 6, 'Sun': 7,
      'Monday': 1, 'Tuesday': 2, 'Wednesday': 3, 'Thursday': 4,
      'Friday': 5, 'Saturday': 6, 'Sunday': 7,
    };
    for (final day in widget.workingDays) {
      if (dayToWeekday[day] == date.weekday) return true;
    }
    return false;
  }

  // Dates that have existing appointments (unavailable)
  final Set<DateTime> _bookedDates = {
    DateTime(2026, DateTime.now().month, DateTime.now().day + 1),
    DateTime(2026, DateTime.now().month, DateTime.now().day + 4),
  };

  bool _isBooked(DateTime day) {
    return _bookedDates.any((d) => d.year == day.year && d.month == day.month && d.day == day.day);
  }

  bool _isPast(DateTime day) {
    final now = DateTime.now();
    return day.isBefore(DateTime(now.year, now.month, now.day));
  }

  bool _isNotWorkingDay(DateTime day) {
    if (widget.workingDays.isEmpty) return false;
    return !_isDoctorWorkingDay(day);
  }

  TimeOfDay _parseTime(String slot) {
    final parts = slot.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    if (parts[1] == 'PM' && hour != 12) hour += 12;
    if (parts[1] == 'AM' && hour == 12) hour = 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _confirmBooking() async {
    final t = _parseTime(_selectedTimeSlot);
    final appointmentStart = DateTime(
      _selectedDay.year, _selectedDay.month, _selectedDay.day,
      t.hour, t.minute,
    );
    final appointmentEnd = appointmentStart.add(const Duration(minutes: 30));
    final dateStr = _formatDate(_selectedDay);

    final pIdStr = healixStore.patientId.value;
    if (pIdStr == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Patient profile not found. Please log in again.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final success = await patientService.createAppointment(
      doctorId: widget.doctorId,
      patientId: int.parse(pIdStr),
      appointmentDate: appointmentStart,
      reason: 'General Consultation',
    );

    if (success) {
      healixStore.setAppointment(widget.doctorName, dateStr, _selectedTimeSlot);

      // Notify doctor and update their schedule (simulated real-time)
      final pName = healixStore.userName.value;
      healixStore.addDoctorAppointment({
        'patientName': pName,
        'appointmentDate': appointmentStart.toIso8601String(),
        'reason': 'General Consultation',
        'status': 'confirmed',
      });

      healixStore.addNotification(
        'New Appointment',
        '$pName booked an appointment for $dateStr at $_selectedTimeSlot',
        target: 'doctor',
      );

      // Show confirmation dialog with calendar option
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => _buildConfirmationDialog(appointmentStart, appointmentEnd, dateStr),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to book appointment. Please try again.'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _monthYear(DateTime d) {
    const months = ['January','February','March','April','May','June',
      'July','August','September','October','November','December'];
    return '${months[d.month - 1]} ${d.year}';
  }

  Future<void> _addToCalendar(DateTime start, DateTime end) async {
    // Format dates for Google Calendar URL (works on web + mobile)
    String _fmt(DateTime d) =>
        '${d.year}${d.month.toString().padLeft(2,'0')}${d.day.toString().padLeft(2,'0')}T'
        '${d.hour.toString().padLeft(2,'0')}${d.minute.toString().padLeft(2,'0')}00';

    final title = Uri.encodeComponent('Medical Appointment — ${widget.doctorName}');
    final details = Uri.encodeComponent(
        'Appointment with ${widget.doctorName} (Cardiologist) at Healix Medical Center.\nTime: $_selectedTimeSlot\n\nBooked via Healix App.');
    final location = Uri.encodeComponent('Healix Medical Center, Cairo');
    final startFmt = _fmt(start);
    final endFmt = _fmt(end);

    final url = Uri.parse(
      'https://calendar.google.com/calendar/render?action=TEMPLATE'
      '&text=$title&dates=$startFmt/$endFmt'
      '&details=$details&location=$location',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open calendar'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  Widget _buildConfirmationDialog(DateTime start, DateTime end, String dateStr) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Builder(builder: (ctx) {
        final isDk = Theme.of(ctx).brightness == Brightness.dark;
        final cCard = isDk ? const Color(0xFF1E293B) : Colors.white;
        final cText = isDk ? Colors.white : const Color(0xFF0F172A);
        final cSub = isDk ? Colors.grey.shade400 : Colors.grey.shade600;

        return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: cCard,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C4D4), Color(0xFF0088CC)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: const Color(0xFF00C4D4).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 20),
              Text('Booking Confirmed!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cText)),
              const SizedBox(height: 8),
              Text('Your appointment has been scheduled.', style: TextStyle(fontSize: 14, color: cSub), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              // Summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDk ? const Color(0xFF0F172A) : const Color(0xFFF0FDFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDk ? Colors.white10 : const Color(0xFFE0F7FA)),
                ),
                child: Column(
                  children: [
                    _summaryRow(Icons.person_outline, widget.doctorName, cText, cSub),
                    const SizedBox(height: 10),
                    _summaryRow(Icons.calendar_month_outlined, dateStr, cText, cSub),
                    const SizedBox(height: 10),
                    _summaryRow(Icons.access_time_outlined, _selectedTimeSlot, cText, cSub),
                    const SizedBox(height: 10),
                    _summaryRow(Icons.location_on_outlined, 'Healix Medical Center', cText, cSub),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Add to Calendar button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _addToCalendar(start, end),
                  icon: const Icon(Icons.calendar_month, size: 20),
                  label: const Text('Add to Calendar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C4D4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text('Back to Home', style: TextStyle(color: cSub, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _summaryRow(IconData icon, String text, Color textColor, Color subColor) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00C4D4), size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle, border: Border.all(color: borderColor)),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor, size: 20),
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text('Book Appointment', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildDoctorCard(),
                const SizedBox(height: 28),
                _buildCalendar(),
                const SizedBox(height: 28),
                _buildTimeSection('Morning', Icons.wb_sunny_outlined, Colors.orange, _morningSlots),
                const SizedBox(height: 20),
                _buildTimeSection('Afternoon', Icons.light_mode, Colors.cyan, _afternoonSlots),
                const SizedBox(height: 20),
                _buildTimeSection('Evening', Icons.nightlight_round, Colors.indigo, _eveningSlots),
                const SizedBox(height: 20),
                _buildSelectedSummaryBadge(),
              ],
            ),
          ),
          // Bottom confirm button
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(top: BorderSide(color: borderColor)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, -4))],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C4D4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      const Text('Confirm & Add to Calendar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C4D4), Color(0xFF0088CC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 40),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.doctorName, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 4),
                  Text(widget.specialty, style: TextStyle(color: const Color(0xFF00AACD), fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 15),
                    const SizedBox(width: 4),
                    Text('4.9', style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13)),
                    const SizedBox(width: 4),
                    Text('(124 reviews)', style: TextStyle(color: subTextColor, fontSize: 12)),
                  ]),
                ],
              )),
            ],
          ),
          if (widget.workingDays.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 13, color: subTextColor),
                const SizedBox(width: 6),
                Text(
                  'Works: ${widget.workingDays.join(', ')}',
                  style: TextStyle(fontSize: 12, color: subTextColor),
                ),
              ],
            ),
          ],
          if (widget.startTimeStr.isNotEmpty && widget.endTimeStr.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 13, color: subTextColor),
                const SizedBox(width: 6),
                Text(
                  '${widget.startTimeStr} – ${widget.endTimeStr}',
                  style: TextStyle(fontSize: 12, color: subTextColor),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          // Month navigation header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.chevron_left, color: textColor, size: 20),
                ),
              ),
              Text(_monthYear(_focusedMonth), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
              GestureDetector(
                onTap: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.chevron_right, color: textColor, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Day of week headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'].map((d) => SizedBox(
              width: 36,
              child: Text(d, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subTextColor)),
            )).toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          _buildCalendarGrid(),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend(const Color(0xFF0088CC), 'Selected'),
              const SizedBox(width: 16),
              _legend(Colors.red.shade300, 'Booked'),
              const SizedBox(width: 16),
              _legend(isDark ? Colors.white24 : Colors.grey.shade300, 'Unavailable'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(fontSize: 11, color: subTextColor)),
    ]);
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startOffset = firstDay.weekday % 7; // Sunday = 0

    final List<Widget> cells = [];

    // Empty cells before first day
    for (int i = 0; i < startOffset; i++) {
      cells.add(const SizedBox(width: 36, height: 36));
    }

    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isSelected = _selectedDay.year == date.year &&
          _selectedDay.month == date.month &&
          _selectedDay.day == date.day;
      final isPast = _isPast(date);
      final isBooked = _isBooked(date);
      final isNotWorking = _isNotWorkingDay(date);
      final isToday = DateTime.now().year == date.year &&
          DateTime.now().month == date.month &&
          DateTime.now().day == date.day;
      final isDisabled = isPast || isBooked || isNotWorking;

      cells.add(GestureDetector(
        onTap: isDisabled ? null : () => setState(() => _selectedDay = date),
        child: Container(
          width: 36, height: 36,
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0088CC)
                : isBooked
                    ? Colors.red.shade100.withOpacity(isDark ? 0.2 : 1)
                    : isNotWorking
                        ? (isDark ? Colors.white.withOpacity(0.03) : Colors.grey.shade50)
                        : isToday
                            ? const Color(0xFF00C4D4).withOpacity(0.15)
                            : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isToday && !isSelected ? Border.all(color: const Color(0xFF00C4D4), width: 1.5) : null,
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : isBooked
                        ? Colors.red.shade400
                        : isNotWorking || isPast
                            ? (isDark ? Colors.white24 : Colors.grey.shade400)
                            : textColor,
              ),
            ),
          ),
        ),
      ));
    }

    // Build rows of 7
    final List<Widget> rows = [];
    for (int i = 0; i < cells.length; i += 7) {
      final end = (i + 7 < cells.length) ? i + 7 : cells.length;
      final rowCells = cells.sublist(i, end);
      while (rowCells.length < 7) rowCells.add(const SizedBox(width: 36, height: 36));
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: rowCells),
      ));
    }

    return Column(children: rows);
  }

  Widget _buildSelectedSummaryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF00C4D4).withOpacity(0.1) : const Color(0xFFE0FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00C4D4).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_available, color: Color(0xFF00C4D4), size: 20),
          const SizedBox(width: 10),
          Expanded(child: RichText(text: TextSpan(
            style: TextStyle(fontSize: 14, color: textColor),
            children: [
              const TextSpan(text: 'Selected: '),
              TextSpan(
                text: '${_formatDate(_selectedDay)} at $_selectedTimeSlot',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0088CC)),
              ),
            ],
          ))),
        ],
      ),
    );
  }

  Widget _buildTimeSection(String title, IconData icon, Color iconColor, List<String> times) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
        ]),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: times.map((time) {
            final isSelected = _selectedTimeSlot == time;
            return GestureDetector(
              onTap: () => setState(() => _selectedTimeSlot = time),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 100,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF0088CC).withOpacity(0.15) : const Color(0xFFE0FAFC))
                      : cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF0088CC) : borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    time,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF0088CC) : textColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
