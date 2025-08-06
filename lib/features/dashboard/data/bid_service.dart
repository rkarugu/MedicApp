import 'package:dio/dio.dart';

class BidService {
  final Dio _dio;

  BidService(this._dio);

  Future<Map<String, dynamic>> applyToBidInvitation({
    required String bidInvitationId,
    required double bidAmount,
  }) async {
    try {
      print('Sending bid acceptance request:');
      print('  URL: /worker/shifts/bid-invitations/$bidInvitationId/apply');
      print('  Method: POST');
      print('  Data: {"bid_amount": $bidAmount}');
      
      final response = await _dio.post(
        '/worker/shifts/bid-invitations/$bidInvitationId/apply',
        data: {
          'bid_amount': bidAmount,
        },
        options: Options(
          method: 'POST', // Explicitly set method
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
          },
        ),
      );
      
      print('Bid acceptance response:');
      print('  Status: ${response.statusCode}');
      print('  Data: ${response.data}');
      
      return {
        'success': true,
        'message': response.data['message'] ?? 'Bid submitted successfully',
        'bid_amount': response.data['bid_amount'] ?? bidAmount,
      };
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['error'] ?? 
                          e.response?.data?['message'] ?? 
                          'Failed to submit bid';
      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred',
      };
    }
  }

  Future<List<Map<String, dynamic>>> getBidInvitations() async {
    try {
      final response = await _dio.get('/worker/shifts/bid-invitations');
      
      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
}
