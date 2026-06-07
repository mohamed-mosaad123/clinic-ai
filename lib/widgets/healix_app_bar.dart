import 'package:flutter/material.dart';
import '../pages/profile_page.dart';
import '../pages/schedule_appointment_page.dart';
import '../store/healix_store.dart';

class HealixAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationTap;
  final List<Widget>? extraActions;

  const HealixAppBar({
    super.key,
    this.onNotificationTap,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.of(context).canPop();

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A), size: 20),
              onPressed: () => Navigator.of(context).pop(),
            )
          : GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Center(
                  child: ValueListenableBuilder<String?>(
                    valueListenable: healixStore.profileImageUrl,
                    builder: (context, url, _) {
                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00AACD),
                          shape: BoxShape.circle,
                          image: url != null
                              ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
                              : null,
                        ),
                        child: url == null
                            ? const Icon(Icons.person_outline, color: Colors.white, size: 24)
                            : null,
                      );
                    },
                  ),
                ),
              ),
            ),
      title: Image.asset(
        'assets/images/logo_full.jpeg',
        height: 32,
        fit: BoxFit.contain,
      ),
      actions: [
        ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: healixStore.notifications,
          builder: (context, notifs, _) {
            final isDoctor = healixStore.doctorId.value != null;
            final filtered = notifs.where((n) {
              final target = n['target'] ?? 'all';
              if (isDoctor) return target == 'doctor' || target == 'all';
              return target == 'patient' || target == 'all';
            }).toList();
            final unreadCount = filtered.where((n) => !(n['isRead'] ?? false)).length;
            
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_outlined, color: Color(0xFF0F172A), size: 26),
                  onPressed: onNotificationTap ?? () => _showNotifications(context, filtered),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        if (extraActions != null) ...extraActions!,
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _showNotifications(BuildContext context, List<Map<String, dynamic>> notifications) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    TextButton(
                      onPressed: () => healixStore.clearNotifications(),
                      child: const Text('Clear All', style: TextStyle(color: Color(0xFF00AACD))),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            const Text('No notifications yet', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                        final note = notifications[index];
                        final Color iconColor = note['color'] ?? const Color(0xFF00AACD);
                        final IconData icon = note['icon'] ?? Icons.notifications_active_outlined;
                        
                        final isAction = note['type'] == 'appointment_action';
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isAction ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(20),
                            border: isAction ? Border.all(color: Colors.red.withOpacity(0.2)) : null,
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isAction ? Colors.red.withOpacity(0.1) : iconColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(isAction ? Icons.warning_amber_rounded : icon, color: isAction ? Colors.red : iconColor, size: 20),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              note['title'] ?? 'Notification',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isAction ? Colors.red.shade900 : Colors.black),
                                            ),
                                            Text(
                                              note['time'] ?? 'Just now',
                                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          note['message'] ?? note['body'] ?? '',
                                          style: TextStyle(color: isAction ? Colors.red.shade800 : Colors.grey[600], fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (note['metadata'] != null && note['metadata']['content'] != null) ...[
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close notifications sheet
                                      _showFullReport(context, note['metadata']);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00AACD),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 0,
                                    ),
                                    child: const Text('View Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ),
                              ],
                              if (isAction) ...[
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        healixStore.clearNotification(note['id']);
                                        healixStore.addNotification(
                                          'Patient Decision: Deleted',
                                          'Patient decided to delete the appointment as requested.',
                                          type: 'doctor',
                                          target: 'doctor',
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment deleted.')));
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        final meta = note['metadata'] ?? {};
                                        final dId = meta['doctorId'];
                                        final dName = meta['doctorName'] ?? 'Doctor';
                                        
                                        healixStore.clearNotification(note['id']);
                                        healixStore.addNotification(
                                          'Patient Decision: Rescheduling',
                                          'Patient has chosen to reschedule the appointment.',
                                          type: 'doctor',
                                          target: 'doctor',
                                        );
                                        
                                        Navigator.pop(context); // Close notification modal
                                        
                                        if (dId != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ScheduleAppointmentPage(
                                                doctorId: dId is int ? dId : int.parse(dId.toString()),
                                                doctorName: dName,
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Doctor information missing.'))
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Reschedule'),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFullReport(BuildContext context, Map<dynamic, dynamic> report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Row(children: [
              const Icon(Icons.description, color: Color(0xFF00AACD), size: 28),
              const SizedBox(width: 12),
              const Text('Medical Report', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ]),
            const SizedBox(height: 8),
            Text('Doctor: Dr. ${report['doctorName'] ?? 'Specialist'}', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            Expanded(child: SingleChildScrollView(child: Text(report['content'] ?? '', style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF334155))))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AACD),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
