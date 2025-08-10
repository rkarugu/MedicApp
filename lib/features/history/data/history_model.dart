class CompletedShift {
  final String id;
  final String facilityName;
  final String position;
  final String date;
  final String startTime;
  final String endTime;
  final double hours;
  final double rate;
  final double total;
  final String status;

  CompletedShift({
    required this.id,
    required this.facilityName,
    required this.position,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.hours,
    required this.rate,
    required this.total,
    required this.status,
  });

  factory CompletedShift.fromJson(Map<String, dynamic> json) =>
      CompletedShift(
        id: json['id']?.toString() ?? '',
        facilityName: json['facilityName'] ?? json['facility_name'] ?? 'Unknown',
        position: json['position'] ?? 'Unknown',
        date: json['date'] ?? '',
        startTime: json['startTime'] ?? json['start_time'] ?? '',
        endTime: json['endTime'] ?? json['end_time'] ?? '',
        hours: (json['hours'] ?? 0.0).toDouble(),
        rate: (json['rate'] ?? 0.0).toDouble(),
        total: (json['total'] ?? 0.0).toDouble(),
        status: json['status'] ?? 'Completed',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'facilityName': facilityName,
        'position': position,
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
        'hours': hours,
        'rate': rate,
        'total': total,
        'status': status,
      };

  DateTime get dateTime => DateTime.parse(date);
}
