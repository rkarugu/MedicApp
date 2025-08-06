import 'package:dio/dio.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/notifications_response.dart';

class MediconnectApi {
  final Dio _dio;
  final String baseUrl;

  MediconnectApi(this._dio, {this.baseUrl = 'http://localhost:8000'}) {
    _dio.options.baseUrl = baseUrl;
  }

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _dio.post('/api/medical-worker/login', data: request.toJson());
    return LoginResponse.fromJson(response.data);
  }

  // Notification endpoints
  Future<NotificationsResponse> getNotifications() async {
    final response = await _dio.get('/api/worker/notifications');
    return NotificationsResponse.fromJson(response.data);
  }

  Future<UnreadCountResponse> getUnreadNotificationCount() async {
    final response = await _dio.get('/api/worker/notifications/unread-count');
    return UnreadCountResponse.fromJson(response.data);
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _dio.patch('/worker/notifications/$notificationId/read');
  }

  Future<void> markAllNotificationsAsRead() async {
    await _dio.patch('/worker/notifications/mark-all-read');
  }

  Future<void> deleteNotification(String notificationId) async {
    await _dio.delete('/api/worker/notifications/$notificationId');
  }
}
