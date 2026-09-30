import 'package:booksbound_app/providers/cart_provider.dart';
import 'package:booksbound_app/routes/app_routes.dart';
import 'package:booksbound_app/services/analytics_service.dart';
import 'package:booksbound_app/services/connectivity_service.dart';
import 'package:booksbound_app/utils/formatters.dart';
import 'package:booksbound_app/utils/haptics.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:booksbound_app/widgets/cached_image.dart';
import 'package:booksbound_app/widgets/empty_state.dart';
import 'package:booksbound_app/widgets/error_snackbar.dart';
import 'package:booksbound_app/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final cartItems = cart.items.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Cart',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: cartItems.isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: "Your cart is empty",
              subtitle: "Browse our catalog and add books you love",
              actionText: "Browse Books",
              onAction: () {
                Haptics.light();
                Navigator.of(context).pushNamed(AppRoutes.categories);
              },
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];

                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedImage(
                            imageUrl: item.book.coverUrl,
                            width: 50,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          item.book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              tooltip: 'Decrease quantity',
                              onPressed: () {
                                Haptics.light();
                                cart.decreaseQuantity(item.book.id);
                              },
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) =>
                                  ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                              child: Text(
                                '${item.quantity}',
                                key: ValueKey<int>(item.quantity),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              tooltip: item.quantity >= item.book.stock
                                  ? 'Maximum stock reached'
                                  : 'Increase quantity',
                              onPressed: item.quantity >= item.book.stock
                                  ? null
                                  : () {
                                      Haptics.light();
                                      if (cart.increaseQuantity(item.book.id) &&
                                          item.quantity >= item.book.stock) {
                                        ScaffoldMessenger.of(context)
                                          ..hideCurrentSnackBar()
                                          ..showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Maximum stock reached for ${item.book.title}.',
                                              ),
                                            ),
                                          );
                                      }
                                    },
                            ),
                            const SizedBox(width: 8),
                            Text(
                              Formatters.formatCurrency(item.totalPrice),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          tooltip: 'Remove from cart',
                          onPressed: () {
                            Haptics.heavy();
                            cart.removeItem(item.book.id);
                          },
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            Formatters.formatCurrency(cart.totalAmount),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        text: 'Checkout',
                        icon: Icons.lock_outline,
                        onPressed: cart.items.isEmpty
                            ? null
                            : () async {
                                final isOnline =
                                    await ConnectivityService.isOnline();
                                if (!isOnline) {
                                  if (!context.mounted) return;
                                  ErrorPresenter.show(
                                    context,
                                    Result.error(
                                      ResultStatus.networkError,
                                      'Cannot checkout while offline. Please check your connection.',
                                    ),
                                  );
                                  return;
                                }

                                AnalyticsService.logBeginCheckout(
                                  total: cart.totalAmount,
                                  itemCount: cart.itemsCount,
                                );
                                if (!context.mounted) return;
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pushNamed(AppRoutes.checkout);
                              },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
