import 'package:booksbound_app/models/order_model.dart';
import 'package:booksbound_app/services/order_service.dart';
import 'package:booksbound_app/utils/formatters.dart';
import 'package:booksbound_app/widgets/cached_image.dart';
import 'package:booksbound_app/widgets/empty_state.dart';
import 'package:flutter/material.dart';

/// Live delivery tracking for one order: a Pending → Processing → Shipped →
/// Delivered timeline that updates as the admin changes the order status.
class OrderTrackingScreen extends StatefulWidget {
  final OrderModel order;
  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  static const _stages = ['Pending', 'Processing', 'Shipped', 'Delivered'];
  static const _stageText = {
    'Pending': 'Order placed and awaiting confirmation',
    'Processing': 'Your books are being packed',
    'Shipped': 'On the way to your address',
    'Delivered': 'Delivered. Enjoy your reading!',
  };
  static const _stageIcons = {
    'Pending': Icons.receipt_long_outlined,
    'Processing': Icons.inventory_2_outlined,
    'Shipped': Icons.local_shipping_outlined,
    'Delivered': Icons.home_outlined,
  };

  late final Stream<OrderModel?> _stream = OrderService().watchOrder(
    widget.order.id,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Order'), centerTitle: true),
      body: StreamBuilder<OrderModel?>(
        stream: _stream,
        initialData: widget.order,
        builder: (context, snapshot) {
          final order = snapshot.data;
          if (order == null) {
            return const EmptyState(
              icon: Icons.search_off,
              title: 'Order not found',
              subtitle: 'It may have been removed',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _summary(context, order),
              const SizedBox(height: 16),
              if (order.status.toLowerCase() == 'cancelled')
                _cancelled(order)
              else
                _timeline(context, order),
              const SizedBox(height: 16),
              _items(order),
            ],
          );
        },
      ),
    );
  }

  Widget _summary(BuildContext context, OrderModel order) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order #${order.id}', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Placed ${Formatters.formatDate(order.createdAt)}'),
            const Divider(height: 24),
            _row(Icons.payments_outlined, 'Payment', order.paymentMethod),
            _row(Icons.location_on_outlined, 'Ship to', order.shippingAddress),
            _row(
              Icons.receipt_outlined,
              'Total',
              Formatters.formatCurrency(order.totalAmount),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _cancelled(OrderModel order) {
    final at = order.reachedAt('Cancelled');
    return Card(
      color: Colors.red.withValues(alpha: 0.08),
      child: ListTile(
        leading: const Icon(Icons.cancel_outlined, color: Colors.red),
        title: const Text('Order cancelled'),
        subtitle: Text(
          at == null
              ? 'This order will not be delivered'
              : 'Cancelled on ${Formatters.formatDate(at)}',
        ),
      ),
    );
  }

  Widget _timeline(BuildContext context, OrderModel order) {
    final current = _stages.indexWhere(
      (s) => s.toLowerCase() == order.status.toLowerCase(),
    );
    final reached = current < 0 ? 0 : current;
    final primary = Theme.of(context).colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < _stages.length; i++)
              _stage(
                stage: _stages[i],
                done: i <= reached,
                isCurrent: i == reached,
                isLast: i == _stages.length - 1,
                at: i <= reached ? order.reachedAt(_stages[i]) : null,
                color: primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _stage({
    required String stage,
    required bool done,
    required bool isCurrent,
    required bool isLast,
    required DateTime? at,
    required Color color,
  }) {
    final dim = Colors.grey.withValues(alpha: 0.5);
    return Semantics(
      label: '$stage: ${done ? 'completed' : 'pending'}',
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: done ? color : dim,
                  child: Icon(
                    _stageIcons[stage],
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: done ? color : dim),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage,
                      style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.bold : null,
                        color: done ? null : Colors.grey,
                      ),
                    ),
                    Text(
                      at != null
                          ? '${_stageText[stage]} · ${Formatters.formatDate(at)}'
                          : _stageText[stage]!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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

  Widget _items(OrderModel order) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          for (final item in order.items)
            ListTile(
              leading: CachedImage(
                imageUrl: item.book.coverUrl,
                width: 40,
                height: 56,
                borderRadius: 4,
              ),
              title: Text(item.book.title),
              subtitle: Text('Qty ${item.quantity}'),
              trailing: Text(Formatters.formatCurrency(item.totalPrice)),
            ),
        ],
      ),
    );
  }
}
