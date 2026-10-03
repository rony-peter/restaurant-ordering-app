import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../api/api_client.dart';
import '../../../../theme/neo_brutalism_theme.dart';
import '../../../../theme/widgets/neo_components.dart';
import '../../../../network/razorpay_web.dart';
import '../../providers/cart_provider.dart';

// --- PAYMENT METHOD SELECTION MODAL ---
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

// --- CHECKOUT BOTTOM SHEET ---
class CheckoutBottomSheet extends ConsumerStatefulWidget {
  const CheckoutBottomSheet({super.key});

  @override
  ConsumerState<CheckoutBottomSheet> createState() => _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends ConsumerState<CheckoutBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showPwaReceipt(BuildContext context, Map<String, dynamic> receiptData) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(6, 6)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'RECEIPT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const Text(
                '--------------------------------',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'monospace'),
              ),
              Text(
                'Order #${receiptData['orderId']?.toString().substring(0, 8) ?? ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...?((receiptData['items'] as List<dynamic>?)?.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item['quantity']}x ${item['name']}',
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                      ),
                      Text(
                        '₹${item['total']}',
                        style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              })),
              const Text(
                '--------------------------------',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'monospace'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL:', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  Text(
                    '₹${receiptData['summary']?['grandTotal'] ?? 0}',
                    style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              NeoButton(
                text: 'CLOSE RECEIPT',
                color: NeoBrutalism.primary,
                onPressed: () => Navigator.of(ctx).pop(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processOrder(String paymentMethod) async {
    final cartState = ref.read(cartProvider);

    if (cartState.restaurantId == null || cartState.tableId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing table or restaurant context')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final apiClient = ApiClient();
      final orderPayload = {
        'restaurantId': cartState.restaurantId,
        'tableId': cartState.tableId,
        'customerName': _nameController.text.trim(),
        'customerPhone': _phoneController.text.trim(),
        'notes': _notesController.text.trim(),
        'paymentMethod': paymentMethod,
        'items': cartState.items.map((item) {
          return {'menuItemId': item.menuItem.id, 'quantity': item.quantity};
        }).toList(),
      };

      final orderResponse = await apiClient.placeOrder(orderPayload);
      final String orderId = orderResponse['id'] ?? orderResponse['orderId'];

      if (!mounted) return;
      Navigator.of(context).pop();

      if (paymentMethod == 'PAY_AT_TABLE') {
        ref.read(cartProvider.notifier).clearCart();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: NeoBrutalism.success,
            behavior: SnackBarBehavior.floating,
            content: Text(
              'ORDER SENT TO KITCHEN! PAY AT TABLE 🚀',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
        );

        try {
          final receiptData = await apiClient.getReceipt(orderId, cartState.restaurantId!);
          if (context.mounted) {
            _showPwaReceipt(context, receiptData);
          }
        } catch (e) {
          debugPrint('Error fetching receipt: $e');
        }
      } else if (paymentMethod == 'ONLINE') {
        final paymentSession = await apiClient.createPaymentCheckout(
          orderId: orderId,
          restaurantId: cartState.restaurantId!,
        );

        if (!mounted) return;

        openRazorpayWebCheckout(
          keyId: paymentSession['keyId'],
          razorpayOrderId: paymentSession['razorpayOrderId'],
          amount: paymentSession['amount'],
          currency: paymentSession['currency'] ?? 'INR',
          restaurantName: 'Restaurant Order',
          contact: _phoneController.text.trim(),
          onSuccess: (paymentId) async {
            ref.read(cartProvider.notifier).clearCart();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: NeoBrutalism.success,
                behavior: SnackBarBehavior.floating,
                content: Text(
                  'PAYMENT SUCCESSFUL & ORDER PLACED! 🚀',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            );

            try {
              final receiptData = await apiClient.getReceipt(orderId, cartState.restaurantId!);
              if (context.mounted) {
                _showPwaReceipt(context, receiptData);
              }
            } catch (e) {
              debugPrint('Error fetching receipt: $e');
            }
          },
          onFailure: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: NeoBrutalism.alert,
                content: Text('Payment cancelled or failed.'),
              ),
            );
          },
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: NeoBrutalism.alert,
          content: Text('Failed to place order: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _handleCheckoutSelection() {
    if (_formKey.currentState?.validate() ?? false) {
      showPaymentMethodModal(
        context: context,
        totalAmount: ref.read(cartProvider).totalAmount,
        onPayOnline: () => _processOrder('ONLINE'),
        onPayAtTable: () => _processOrder('PAY_AT_TABLE'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: NeoBrutalism.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: Colors.black, width: 3),
          left: BorderSide(color: Colors.black, width: 3),
          right: BorderSide(color: Colors.black, width: 3),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'YOUR CART',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(color: Colors.black, thickness: 2),
            const SizedBox(height: 12),

            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cartState.items.length,
                itemBuilder: (context, index) {
                  final item = cartState.items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x  ${item.menuItem.name}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          '₹${item.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Customer Name Input Field
            TextFormField(
              controller: _nameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Your Name *',
                labelStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: NeoBrutalism.primary,
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Customer Mobile Number Input Field
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your mobile number';
                }
                if (value.trim().length < 10) {
                  return 'Enter a valid mobile number';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Mobile Number *',
                labelStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: NeoBrutalism.primary,
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Kitchen Notes Input Field
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Kitchen Notes (e.g., No onions, extra sauce)',
                labelStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: NeoBrutalism.primary,
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹${cartState.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: NeoBrutalism.primary,
                      ),
                    ),
                  ],
                ),
                _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.black)
                    : NeoButton(
                        text: 'SELECT PAYMENT 🚀',
                        color: NeoBrutalism.success,
                        onPressed: () {
                          if (cartState.items.isNotEmpty) {
                            _handleCheckoutSelection();
                          }
                        },
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}