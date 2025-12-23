enum AttendanceStatus {
  absent,
  checkedIn,
  completed,
  overtime,
  shortage,
}

class AttendanceLog {
  final DateTime date;
  String? checkIn;
  String? checkOut;
  Duration totalHours;
  AttendanceStatus status;

  AttendanceLog({
    required this.date,
    this.checkIn,
    this.checkOut,
    this.totalHours = Duration.zero,
    this.status = AttendanceStatus.absent,
  });
}
