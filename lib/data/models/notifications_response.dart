import 'notification_model.dart';

class NotificationsResponse {
  final bool success;
  final List<NotificationModel> data;
  final int total;

  NotificationsResponse({
    required this.success,
    required this.data,
    required this.total,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return NotificationsResponse(
      success: json['success'] as bool? ?? false,
      data: dataList
          .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
      'total': total,
    };
  }
}

class UnreadCountResponse {
  final bool success;
  final int unreadCount;

  UnreadCountResponse({
    required this.success,
    required this.unreadCount,
  });

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponse(
      success: json['success'] as bool? ?? false,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'unread_count': unreadCount,
    };
  }
}
