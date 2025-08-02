import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dashboard_models.dart';
import '../data/bid_service.dart';
import '../../../core/providers.dart';

class BidInvitationDetailScreen extends ConsumerStatefulWidget {
  final BidInvitation bidInvitation;

  const BidInvitationDetailScreen({
    super.key,
    required this.bidInvitation,
  });

  @override
  ConsumerState<BidInvitationDetailScreen> createState() => _BidInvitationDetailScreenState();
}

class _BidInvitationDetailScreenState extends ConsumerState<BidInvitationDetailScreen> {
  final _bidAmountController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _bidAmountController.dispose();
    super.dispose();
  }

  Future<void> _submitBid() async {
    final bidAmount = double.tryParse(_bidAmountController.text);
    
    if (bidAmount == null) {
      setState(() => _error = 'Please enter a valid amount');
      return;
    }

    if (bidAmount < widget.bidInvitation.minimumBid) {
      setState(() => _error = 'Bid must be at least \$${widget.bidInvitation.minimumBid}');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final bidService = BidService(ref.read(authenticatedDioProvider));
    final result = await bidService.applyToBidInvitation(
      bidInvitationId: widget.bidInvitation.invitationId,
      bidAmount: bidAmount,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      Navigator.pop(context, true);
    } else {
      setState(() => _error = result['error']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bid Invitation'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.business, color: Colors.purple),
                        const SizedBox(width: 8),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.bidInvitation.facility,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Shift Time', widget.bidInvitation.shiftTime),
                    _buildDetailRow('Minimum Bid', '\$${widget.bidInvitation.minimumBid}'),
                    _buildDetailRow('Status', widget.bidInvitation.status, 
                      color: widget.bidInvitation.status == 'new' ? Colors.green : Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Submit Your Bid',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bidAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Your Bid Amount',
                prefixText: '\$',
                border: OutlineInputBorder(),
                errorText: _error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Minimum bid: \$${widget.bidInvitation.minimumBid}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitBid,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Bid',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
