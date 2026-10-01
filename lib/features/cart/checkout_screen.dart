import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:booksbound_app/features/addresses/addresses_screen.dart';
import 'package:booksbound_app/features/checkout/order_success_screen.dart';
import 'package:booksbound_app/features/payment_methods/payment_methods_screen.dart';
import 'package:booksbound_app/models/address_model.dart';
import 'package:booksbound_app/models/order_model.dart';
import 'package:booksbound_app/models/payment_method_model.dart';
import 'package:booksbound_app/providers/cart_provider.dart';
import 'package:booksbound_app/providers/user_auth_provider.dart';
import 'package:booksbound_app/services/account_details_service.dart';
import 'package:booksbound_app/services/order_service.dart';
import 'package:booksbound_app/utils/formatters.dart';
import 'package:booksbound_app/utils/haptics.dart';
import 'package:booksbound_app/utils/page_transitions.dart';
import 'package:booksbound_app/utils/validators.dart';
import 'package:booksbound_app/widgets/error_snackbar.dart';
import 'package:booksbound_app/widgets/primary_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const _cashOnDelivery = 'Cash on Delivery';
  static const _newAddress = '__new__';

  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _accountDetails = AccountDetailsService();
  late final Stream<List<AddressModel>> _addresses = _accountDetails
      .watchAddresses();
  late final Stream<List<PaymentMethodModel>> _cards = _accountDetails
      .watchPaymentMethods();
  bool _isLoading = false;

  /// Latest saved addresses, the selected id (or [_newAddress] to type one
  /// in), and an address just added from checkout to select once it arrives.
  List<AddressModel> _savedAddresses = const [];
  String? _addressId;
  String? _selectAfterSave;

  /// Selected payment label ("Visa •••• 4242" or [_cashOnDelivery]).
  String? _payment;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;
    final selected = _savedAddresses
        .where((a) => a.id == _addressId)
        .firstOrNull;
    final shippingAddress =
        selected?.formatted ?? _addressController.text.trim();

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

    final now = DateTime.now();
    final order = OrderModel(
      id: now.millisecondsSinceEpoch.toString(),
      userId: authProvider.user!.uid,
      items: cartProvider.itemList,
      totalAmount: cartProvider.totalPrice,
      shippingAddress: shippingAddress,
      status: 'Pending',
      createdAt: now,
      paymentMethod: _payment ?? _cashOnDelivery,
      statusHistory: [OrderStatusEvent(status: 'Pending', at: now)],
    );

    final result = await OrderService().createOrder(order);
    if (!result.isSuccess) {
      if (mounted) {
        ErrorPresenter.show(context, result);
        setState(() => _isLoading = false);
      }
      return;
    }

    cartProvider.clearCart();
    Haptics.success();
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.of(context, rootNavigator: true).pushReplacement(
        FadeRoute(
          page: OrderSuccessScreen(
            orderId: order.id,
            totalAmount: order.totalAmount,
          ),
        ),
      );
    }
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );

  Widget _addressSection() {
    return StreamBuilder<List<AddressModel>>(
      stream: _addresses,
      builder: (context, snapshot) {
        final saved = snapshot.data ?? const <AddressModel>[];
        _savedAddresses = saved;
        final justAdded = saved
            .where((a) => a.formatted == _selectAfterSave)
            .firstOrNull;
        if (justAdded != null) {
          _addressId = justAdded.id;
          _selectAfterSave = null;
        } else if (saved.isNotEmpty &&
            _addressId != _newAddress &&
            !saved.any((a) => a.id == _addressId)) {
          // Nothing (or a since-deleted address) selected: use the default.
          _addressId = saved
              .firstWhere((a) => a.isDefault, orElse: () => saved.first)
              .id;
        }
        final useNew = saved.isEmpty || _addressId == _newAddress;
        return RadioGroup<String>(
          groupValue: _addressId,
          onChanged: (id) => setState(() => _addressId = id),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final address in saved)
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: address.id,
                  title: Text(address.label),
                  subtitle: Text(address.formatted),
                ),
              if (saved.isNotEmpty)
                const RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: _newAddress,
                  title: Text('Use a different address'),
                ),
              if (useNew)
                TextFormField(
                  key: const Key('checkout_address_field'),
                  controller: _addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Shipping Address',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      Validators.validateRequired(val, 'Shipping Address'),
                ),
              TextButton.icon(
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Save a new address'),
                onPressed: () async {
                  final added = await showAddressForm(context);
                  if (added != null && mounted) {
                    setState(() => _selectAfterSave = added.formatted);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _paymentSection() {
    return StreamBuilder<List<PaymentMethodModel>>(
      stream: _cards,
      builder: (context, snapshot) {
        final cards = snapshot.data ?? const <PaymentMethodModel>[];
        final stale =
            _payment != null &&
            _payment != _cashOnDelivery &&
            snapshot.hasData &&
            !cards.any((c) => c.label == _payment);
        if ((_payment == null || stale) && snapshot.hasData) {
          final preferred = cards.where((c) => c.isDefault);
          _payment = preferred.isEmpty
              ? _cashOnDelivery
              : preferred.first.label;
        }
        return RadioGroup<String>(
          groupValue: _payment ?? _cashOnDelivery,
          onChanged: (v) => setState(() => _payment = v),
          child: Column(
            children: [
              const RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                value: _cashOnDelivery,
                secondary: Icon(Icons.payments_outlined),
                title: Text(_cashOnDelivery),
              ),
              for (final card in cards)
                RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: card.label,
                  secondary: const Icon(Icons.credit_card),
                  title: Text(card.label),
                  subtitle: Text('Expires ${card.expiry}'),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.add_card),
                  label: const Text('Add a card'),
                  onPressed: () async {
                    final added = await showPaymentMethodForm(context);
                    if (added != null && mounted) {
                      setState(() => _payment = added.label);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Text(
                    'Total: ${Formatters.formatCurrency(cartProvider.totalPrice)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${cartProvider.itemList.length} item(s)',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  _sectionTitle('Shipping Address'),
                  _addressSection(),
                  _sectionTitle('Payment Method'),
                  _paymentSection(),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PrimaryButton(
                  text: 'Place Order',
                  icon: Icons.check_circle_outline,
                  isLoading: _isLoading,
                  onPressed: _processCheckout,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
