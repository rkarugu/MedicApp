import 'package:flutter/material.dart';
import '../data/models/notification_model.dart';
import '../data/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;
  
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  NotificationProvider(this._notificationService);

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load notifications from API
  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _notificationService.getNotifications();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _notifications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load unread count
  Future<void> loadUnreadCount() async {
    try {
      _unreadCount = await _notificationService.getUnreadCount();
      notifyListeners();
    } catch (e) {
      // Log error but don't show to user for count updates
      debugPrint('Error loading unread count: $e');
    }
  }

  /// Refresh both notifications and unread count
  Future<void> refreshNotifications() async {
    await Future.wait([
      loadNotifications(),
      loadUnreadCount(),
    ]);
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          type: _notifications[index].type,
          data: _notifications[index].data,
          readAt: DateTime.now().toIso8601String(),
          createdAt: _notifications[index].createdAt,
          updatedAt: _notifications[index].updatedAt,
        );
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      
      // Update local state
      _notifications = _notifications.map((notification) => NotificationModel(
        id: notification.id,
        type: notification.type,
        data: notification.data,
        readAt: DateTime.now().toIso8601String(),
        createdAt: notification.createdAt,
        updatedAt: notification.updatedAt,
      )).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      
      // Update local state
      _notifications.removeWhere((n) => n.id == notificationId);
      if (_notifications.any((n) => n.id == notificationId && !n.isRead)) {
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
