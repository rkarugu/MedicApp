import 'package:dio/dio.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/models/notifications_response.dart';
import 'dashboard_models.dart';

class NotificationDashboardService {
  final Dio _dio;

  NotificationDashboardService(this._dio);

  Future<List<BidInvitation>> getBidInvitationsFromNotifications() async {
    try {
      final response = await _dio.get('/worker/shifts/bid-invitations');
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => BidInvitation(
          invitationId: item['invitationId'] ?? 0,
          facility: item['facility'] ?? 'Medical Facility',
          shiftTime: item['shiftTime'] ?? 'TBD',
          minimumBid: item['minimumBid'] ?? 0,
          status: item['status'] ?? 'new',
          title: item['title'] ?? 'New Shift',
        )).toList();
      }
      
      return [];
    } catch (e) {
      print('Error loading bid invitations: $e');
      return [];
    }
  }

  Future<int> getUnreadBidInvitationsCount() async {
    try {
      final response = await _dio.get('/api/worker/notifications/unread-count');
      final countResponse = UnreadCountResponse.fromJson(response.data);
      return countResponse.unreadCount;
    } catch (e) {
      return 0;
    }
  }

  Future<void> markBidInvitationAsRead(int invitationId) async {
    try {
      await _dio.patch('/api/worker/notifications/$invitationId/read');
    } catch (e) {
      print('Error marking bid invitation as read: $e');
    }
  }
}
