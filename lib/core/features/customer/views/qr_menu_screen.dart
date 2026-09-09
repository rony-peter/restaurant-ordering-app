import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../api/api_client.dart';
import '../../../theme/neo_brutalism_theme.dart';
import '../../../theme/widgets/neo_components.dart';
import '../models/menu_models.dart';
import '../providers/cart_provider.dart';
import 'widgets/checkout_bottom_sheet.dart';

// Provider to fetch QR table details and menu items
final menuFutureProvider = FutureProvider.family<List<MenuItem>, String>((
  ref,
  qrToken,
) async {
  final apiClient = ApiClient();

  // 1. Resolve QR token to get table & restaurant context
  final tableData = await apiClient.resolveQrToken(qrToken);
  final String restaurantId = tableData['restaurantId'];
  final String tableId = tableData['id'];

  // 2. Pass context to Cart State
  ref.read(cartProvider.notifier).setTableContext(restaurantId, tableId);

  // 3. Fetch menu for this restaurant
  final rawMenu = await apiClient.fetchMenu(restaurantId);
  return rawMenu.map((item) => MenuItem.fromJson(item)).toList();
});

class QrMenuScreen extends ConsumerWidget {
  final String qrToken;

  const QrMenuScreen({super.key, required this.qrToken});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final menuAsyncValue = ref.watch(menuFutureProvider(qrToken));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TABLE MENU ($qrToken)',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: NeoBrutalism.secondary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.5),
          child: Container(color: Colors.black, height: 2.5),
        ),
      ),
      body: menuAsyncValue.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.black)),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: NeoCard(
              backgroundColor: const Color(0xFFFFCDD2),
              child: Text(
                'Failed to load menu: $err',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        data: (menuItems) => Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(16).copyWith(bottom: 100),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final cartItem = cartState.items.firstWhere(
                  (i) => i.menuItem.id == item.id,
                  orElse: () => CartItem(menuItem: item, quantity: 0),
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: NeoCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.description,
                                style: const TextStyle(color: Colors.black87),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\₹${item.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: NeoBrutalism.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Quantity Selector Controls
                        Container(
                          decoration: BoxDecoration(
                            color: NeoBrutalism.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (cartItem.quantity > 0) ...[
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 18),
                                  onPressed: () =>
                                      cartNotifier.removeItem(item.id),
                                ),
                                Text(
                                  '${cartItem.quantity}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: () => cartNotifier.addItem(item),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Floating Cart Summary Bar
            if (cartState.totalItemCount > 0)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: NeoCard(
                  backgroundColor: NeoBrutalism.primary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${cartState.totalItemCount} ITEMS',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '\₹${cartState.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      NeoButton(
                        text: 'CHECKOUT',
                        color: NeoBrutalism.secondary,
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const CheckoutBottomSheet(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
