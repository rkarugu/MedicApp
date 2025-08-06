import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_models.dart';
import '../application/dashboard_provider.dart';
import 'bid_invitation_detail_screen.dart';

class BidInvitationsListScreen extends ConsumerWidget {
  const BidInvitationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Enable auto-refresh for real-time notifications
    ref.watch(dashboardAutoRefreshProvider);
    
    final dashboardAsync = ref.watch(dashboardProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bid Invitations'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Force refresh the dashboard data
              ref.invalidate(dashboardProvider);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Force refresh the dashboard data
          ref.invalidate(dashboardProvider);
          // Wait for the new data to load
          await ref.read(dashboardProvider.future);
        },
        child: dashboardAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${err.toString()}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(dashboardProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (data) {
            if (data.bidInvitations.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 100),
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.gavel, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No bid invitations available',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Pull down to refresh',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: data.bidInvitations.length,
              itemBuilder: (context, index) {
              final invitation = data.bidInvitations[index];
                return BidInvitationCard(
                  invitation: invitation,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BidInvitationDetailScreen(
                          bidInvitation: invitation,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class BidInvitationCard extends StatelessWidget {
  final BidInvitation invitation;
  final VoidCallback onTap;

  const BidInvitationCard({
    super.key,
    required this.invitation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    invitation.facility,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: invitation.status == 'new' 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      invitation.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: invitation.status == 'new' 
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Shift: ${invitation.shiftTime}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Minimum Bid: \$${invitation.minimumBid}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onTap,
                    child: const Text(
                      'View Details',
                      style: TextStyle(color: Colors.purple),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
