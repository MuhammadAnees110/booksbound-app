import 'package:flutter/material.dart';
import 'package:booksbound_app/models/order_model.dart';
import 'package:booksbound_app/services/order_service.dart';
import 'package:booksbound_app/utils/formatters.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:booksbound_app/widgets/error_snackbar.dart';

class ManageOrdersScreen extends StatelessWidget {
  const ManageOrdersScreen({super.key});

  static const List<String> _statuses = [
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.amber.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        centerTitle: true,
      ),
      body: StreamBuilder<Result<List<OrderModel>>>(
        stream: orderService.getAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final result = snapshot.data;
          if (result != null && !result.isSuccess) {
            return Center(child: Text(result.message));
          }

          final orders = result?.data ?? [];

          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No orders found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final statusColor = _getStatusColor(order.status);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withValues(alpha: 0.15),
                    child: Icon(Icons.receipt_long, color: statusColor),
                  ),
                  title: Text(
                    'Order #${order.id.length > 6 ? order.id.substring(0, 6) : order.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${Formatters.formatDate(order.createdAt)} • ${Formatters.formatCurrency(order.totalAmount)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  trailing: DropdownButton<String>(
                    value: _statuses.contains(order.status)
                        ? order.status
                        : 'Pending',
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, size: 20),
                    items: _statuses.map((status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(status),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newStatus) async {
                      if (newStatus != null && newStatus != order.status) {
                        final res = await orderService.updateOrderStatus(order.id, newStatus);
                        if (!context.mounted) return;
                        if (res.isSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Order status updated to $newStatus'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        } else {
                          ErrorPresenter.show(context, res);
                        }
                      }
                    },
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          const Text(
                            'Shipping Address:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.shippingAddress.isEmpty
                                ? 'No address provided'
                                : order.shippingAddress,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Items:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...order.items.map((item) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.book.title} (x${item.quantity})',
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      Formatters.formatCurrency(item.totalPrice),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
