import 'package:booksbound_app/constants/app_dimensions.dart';
import 'package:booksbound_app/utils/haptics.dart';
import 'package:booksbound_app/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String orderId;
  final double totalAmount;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  @override
  void initState() {
    super.initState();
    Haptics.success();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Animated Success Checkmark Circle
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.green,
                    size: 64,
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.4, 0.4),
                      end: const Offset(1.0, 1.0),
                      curve: Curves.elasticOut,
                      duration: 800.ms,
                    )
                    .fadeIn(duration: 300.ms),

                const SizedBox(height: 28),

                // Order Placed Title
                Text(
                  "Order Placed!",
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    letterSpacing: -0.5,
                  ),
                )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  "Thank you for your purchase. We're getting your books ready to ship!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    height: 1.4,
                  ),
                )
                    .animate(delay: 350.ms)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 32),

                // Order Details Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    border: Border.all(
                      color: theme.colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Order Reference",
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            "#${widget.orderId.substring(0, widget.orderId.length > 8 ? 8 : widget.orderId.length).toUpperCase()}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: theme.dividerTheme.color, height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Estimated Delivery",
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                          const Row(
                            children: [
                              Icon(Icons.local_shipping_outlined, size: 16, color: Colors.green),
                              SizedBox(width: 4),
                              Text(
                                "3 - 5 Business Days",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1),

                const Spacer(),

                // Continue Shopping CTA
                PrimaryButton(
                  text: "Continue Shopping",
                  icon: Icons.shopping_bag_outlined,
                  onPressed: () {
                    Haptics.light();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                )
                    .animate(delay: 700.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
