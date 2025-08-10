import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dashboard_models.dart';
import '../../application/dashboard_provider.dart';
import '../../data/shift_application_models.dart';
import '../utils/bid_utils.dart';
import '../dashboard_page.dart';
import '../bid_invitations_list_screen.dart';
import 'bid_invitation_notification_card.dart';
import 'shift_application_card.dart';
import 'upcoming_shift_card.dart';

class DashboardCards extends ConsumerWidget {
  final DashboardData data;
  const DashboardCards({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Filter out completed shift applications for dashboard display
    final activeShiftApplications = data.shiftApplications.where((app) => app.status != 'completed').toList();
    
    final List<_DashboardItem> dashboardItems = [
      _DashboardItem(title: 'Upcoming Shifts', count: data.upcomingShifts.length, icon: Icons.access_time, color: Colors.blue),
      _DashboardItem(title: 'Instant Requests', count: data.instantRequests.length, icon: Icons.flash_on, color: Colors.orange),
      _DashboardItem(title: 'Bid Invitations', count: data.bidInvitations.length, icon: Icons.gavel, color: Colors.purple),
      _DashboardItem(title: 'Shift Applications', count: activeShiftApplications.length, icon: Icons.assignment, color: Colors.green),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.5, 
          ),
          itemCount: dashboardItems.length,
          itemBuilder: (context, index) {
            final item = dashboardItems[index];
            return _DashboardGridCard(item: item);
          },
        ),
        const SizedBox(height: 24),
        if (data.upcomingShifts.isNotEmpty) ...[
          const _SectionHeader(title: 'Upcoming Shifts'),
          ...data.upcomingShifts.map((shift) => UpcomingShiftCard(
            shift: shift,
            onRefresh: () {
              // Trigger dashboard refresh
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const DashboardPage(),
                  ),
                );
              }
            },
          )),
        ],
        const SizedBox(height: 24),
        if (data.bidInvitations.isNotEmpty) ...[
          const _SectionHeader(title: 'Recent Bid Invitations'),
          ...data.bidInvitations.take(5).map((invitation) => BidInvitationNotificationCard(
            invitation: invitation,
            onAccept: () {
              // Handle bid acceptance
              handleBidAcceptance(context, ref, invitation);
            },
          )),
          const SizedBox(height: 16),
        ],
        if (activeShiftApplications.isNotEmpty) ...[  
          const _SectionHeader(title: 'Shift Applications'),
          ...activeShiftApplications.take(5).map((application) => ShiftApplicationCard(
            application: application,
            onStatusChanged: () {
              // Trigger dashboard refresh when shift status changes
              ref.read(dashboardRefreshProvider)();
            },
          )),
          const SizedBox(height: 16),
        ],
        if (data.shiftHistory.isNotEmpty) ...[
          const _SectionHeader(title: 'Shift History'),
          ...data.shiftHistory.map((shift) => _ShiftHistoryCard(shift: shift)),
        ],
      ],
    );
  }
}

class _DashboardItem {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  _DashboardItem({required this.title, required this.count, required this.icon, required this.color});
}

class _DashboardGridCard extends StatelessWidget {
  final _DashboardItem item;

  const _DashboardGridCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (item.title == 'Bid Invitations') {
            // Navigate to bid invitations list or detail
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BidInvitationsListScreen(),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(item.icon, color: item.color, size: 28),
                  Text(item.count.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
  );
}

class _ShiftHistoryCard extends StatelessWidget {
  final Shift shift;
  const _ShiftHistoryCard({required this.shift});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.history, color: Colors.grey),
        ),
        title: Text(shift.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${shift.facility}\n${shift.startTime} - ${shift.endTime}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('Earnings', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('KES ${shift.earnings ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}


