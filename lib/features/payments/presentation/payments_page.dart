import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/mediconnect_app_bar.dart';

class PaymentsPage extends ConsumerWidget {
  const PaymentsPage({super.key});

  static const String routeName = 'payments';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const MediconnectAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text('Total Earnings', style: TextStyle(fontSize: 18, color: Colors.blueGrey)),
                    const SizedBox(height: 8),
                    Text('KES 120,000', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text('Recent Transactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...List.generate(5, (index) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: const Icon(Icons.payment, color: Colors.blue),
                ),
                title: Text('Payment #${index + 1}'),
                subtitle: Text('2025-06-2${5-index}'),
                trailing: Text(
                  '+KES ${[5000, 8000, 12000, 7000, 9500][index]}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
