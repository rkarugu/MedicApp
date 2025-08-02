import 'package:dio/dio.dart';
import '../api/mediconnect_api.dart';
import '../models/notification_model.dart';
import '../models/notifications_response.dart';

class NotificationService {
  final MediconnectApi _api;

  NotificationService(this._api);

  /// Get all notifications for the current medical worker
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _api.getNotifications();
      if (response.success) {
        return response.data;
      }
      throw Exception('Failed to load notifications');
    } on DioException catch (e) {
      throw Exception('Failed to load notifications: ${e.message}');
    }
  }

  /// Get the count of unread notifications
  Future<int> getUnreadCount() async {
    try {
      final response = await _api.getUnreadNotificationCount();
      if (response.success) {
        return response.unreadCount;
      }
      throw Exception('Failed to get unread count');
    } on DioException catch (e) {
      throw Exception('Failed to get unread count: ${e.message}');
    }
  }

  /// Mark a specific notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _api.markNotificationAsRead(notificationId);
    } on DioException catch (e) {
      throw Exception('Failed to mark notification as read: ${e.message}');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _api.markAllNotificationsAsRead();
    } on DioException catch (e) {
      throw Exception('Failed to mark all notifications as read: ${e.message}');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _api.deleteNotification(notificationId);
    } on DioException catch (e) {
      throw Exception('Failed to delete notification: ${e.message}');
    }
  }
}
