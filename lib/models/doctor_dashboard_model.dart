class DoctorDashboardData {
  final String date;
  final String greeting;
  final int labsPending;
  final int dailyPatients;
  final List<Appointment> todaySchedule;
  final List<LabReview> pendingLabs;
  final List<Activity> recentActivity;
  final List<Insight> insights;

  DoctorDashboardData({
    required this.date,
    required this.greeting,
    required this.labsPending,
    required this.dailyPatients,
    required this.todaySchedule,
    required this.pendingLabs,
    required this.recentActivity,
    required this.insights,
  });
}

class Appointment {
  final String time;
  final String period;
  final String patientName;
  final String type;
  final bool isNext;

  Appointment({
    required this.time,
    required this.period,
    required this.patientName,
    required this.type,
    this.isNext = false,
  });
}

class LabReview {
  final String title;
  final String patientName;
  final String status;
  final bool isCritical;

  LabReview({
    required this.title,
    required this.patientName,
    required this.status,
    required this.isCritical,
  });
}

class Activity {
  final String title;
  final String subtitle;
  final String time;
  final String type; // e.g., 'notes', 'prescription', 'call'

  Activity({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
  });
}

class Insight {
  final String label;
  final String title;
  final String subtitle;
  final List<double> data;
  final String type; // 'bar' or 'circular'

  Insight({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.data,
    required this.type,
  });
}
