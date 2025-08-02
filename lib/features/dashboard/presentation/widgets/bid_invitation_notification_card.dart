import 'package:flutter/material.dart';
import '../../data/dashboard_models.dart';

// Bid Invitation Notification Card
class BidInvitationNotificationCard extends StatelessWidget {
  final BidInvitation invitation;
  final VoidCallback onAccept;

  const BidInvitationNotificationCard({
    super.key,
    required this.invitation,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: Colors.purple.shade100,
          child: const Icon(Icons.gavel, color: Colors.purple),
        ),
        title: Text(
          invitation.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(invitation.facility),
            Text(
              'Shift: ${_formatDateTime(invitation.shiftTime)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Text(
              'Min Bid: KES ${invitation.minimumBid}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onAccept,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Accept'),
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }
}

// Handle bid acceptance
void handleBidAcceptance(BuildContext context, BidInvitation invitation) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Accept Bid Invitation'),
        content: Text(
          'Do you want to apply for this shift: ${invitation.title} at ${invitation.facility}?\n\nMinimum Bid: KES ${invitation.minimumBid}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Call API to accept bid invitation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Application submitted for ${invitation.title}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept'),
          ),
        ],
      );
    },
  );
}
