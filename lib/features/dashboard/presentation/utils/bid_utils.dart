import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dashboard_models.dart';
import '../../data/bid_service.dart';
import '../../application/dashboard_provider.dart';
import '../../../../core/providers.dart';

// Handle bid acceptance
void handleBidAcceptance(BuildContext context, WidgetRef ref, BidInvitation invitation) async {
  // Show confirmation dialog
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Accept Bid Invitation'),
      content: Text('Are you sure you want to accept this bid invitation for ${invitation.title}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Accept'),
        ),
      ],
    ),
  ) ?? false;

  if (!confirmed || !context.mounted) return;

  try {
    // Get authenticated Dio instance
    final dio = ref.read(authenticatedDioProvider);
    final bidService = BidService(dio);

    // Submit bid acceptance
    print('Initiating bid acceptance for invitation ID: ${invitation.invitationId}');
    final result = await bidService.applyToBidInvitation(
      bidInvitationId: invitation.invitationId,
      bidAmount: invitation.minimumBid.toDouble(),
    );

    // Show result
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] == true 
                ? 'Successfully accepted bid invitation!'
                : 'Failed to accept bid: ${result['error'] ?? 'Unknown error'}',
          ),
          backgroundColor: result['success'] == true ? null : Colors.red,
        ),
      );
    }

    // Trigger immediate dashboard refresh if successful
    if (result['success'] == true) {
      // Refresh dashboard data immediately to show updated state
      ref.read(dashboardRefreshProvider)();
    }
  } catch (e, stackTrace) {
    print('Error in bid acceptance:');
    print(e);
    print(stackTrace);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while processing your request. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
