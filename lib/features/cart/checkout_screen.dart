import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:booksbound_app/providers/cart_provider.dart';
import 'package:booksbound_app/providers/user_auth_provider.dart';
import 'package:booksbound_app/services/order_service.dart';
import 'package:booksbound_app/models/order_model.dart';
import 'package:booksbound_app/utils/formatters.dart';
import 'package:booksbound_app/utils/haptics.dart';
import 'package:booksbound_app/utils/validators.dart';
import 'package:booksbound_app/widgets/primary_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<UserAuthProvider>(context, listen: false);

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to place an order.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final order = OrderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: authProvider.user!.uid,
      items: cartProvider.itemList,
      totalAmount: cartProvider.totalPrice,
      shippingAddress: _addressController.text.trim(),
      status: 'Pending',
      createdAt: DateTime.now(),
    );

    try {
      await OrderService().createOrder(order);
      cartProvider.clearCart();
      Haptics.success();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total: ${Formatters.formatCurrency(cartProvider.totalPrice)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Shipping Address',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    Validators.validateRequired(val, 'Shipping Address'),
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Place Order',
                icon: Icons.check_circle_outline,
                isLoading: _isLoading,
                onPressed: _processCheckout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
