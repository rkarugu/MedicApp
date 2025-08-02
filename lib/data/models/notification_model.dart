class NotificationModel {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final String? readAt;
  final String createdAt;
  final String updatedAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.data,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      readAt: json['read_at']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'read_at': readAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  bool get isRead => readAt != null;

  String get title => data['title']?.toString() ?? 'New Notification';
  String get message => data['message']?.toString() ?? 'You have a new notification';
  String? get shiftId => data['shift_id']?.toString();
  String? get facilityName => data['facility_name']?.toString();
}
