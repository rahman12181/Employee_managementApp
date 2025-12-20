class AttendanceLog {
  final DateTime date;
  String? checkIn;
  String? checkOut;
  Duration totalHours;

  AttendanceLog({
    required this.date,
    this.checkIn,
    this.checkOut,
    this.totalHours = Duration.zero,
  });
}
