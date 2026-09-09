import 'package:flutter/material.dart';

void showPaymentMethodModal({
  required BuildContext context,
  required double totalAmount,
  required VoidCallback onPayOnline,
  required VoidCallback onPayAtTable,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Option',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Total Payable: ₹${totalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            // Option 1: Pay Online Now
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: const Icon(Icons.payment_rounded, color: Colors.blue, size: 28),
                title: const Text('Pay Online Now', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('UPI, Credit/Debit Cards, Netbanking'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  onPayOnline();
                },
              ),
            ),

            const SizedBox(height: 12),

            // Option 2: Pay at Table / Cash
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: const Icon(Icons.storefront_rounded, color: Colors.green, size: 28),
                title: const Text('Pay at Table / Cash', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Send order to kitchen and pay the staff later'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  onPayAtTable();
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}