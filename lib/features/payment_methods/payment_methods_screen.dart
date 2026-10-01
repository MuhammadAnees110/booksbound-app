import 'package:booksbound_app/models/payment_method_model.dart';
import 'package:booksbound_app/services/account_details_service.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:booksbound_app/utils/validators.dart';
import 'package:booksbound_app/widgets/empty_state.dart';
import 'package:booksbound_app/widgets/error_snackbar.dart';
import 'package:booksbound_app/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _service = AccountDetailsService();
  late final Stream<List<PaymentMethodModel>> _stream = _service
      .watchPaymentMethods();

  Future<void> _report(Result<void> result, String success) async {
    if (!mounted) return;
    if (result.isSuccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(success)));
    } else {
      ErrorPresenter.show(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Methods'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add_card_button'),
        icon: const Icon(Icons.add_card),
        label: const Text('Add Card'),
        onPressed: () => showPaymentMethodForm(context),
      ),
      body: StreamBuilder<List<PaymentMethodModel>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const EmptyState(
              icon: Icons.error_outline,
              title: 'Unable to load payment methods',
              subtitle: 'Please try again later',
            );
          }
          final methods = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
            children: [
              const Card(
                child: ListTile(
                  leading: Icon(Icons.payments_outlined),
                  title: Text('Cash on Delivery'),
                  subtitle: Text('Always available at checkout'),
                ),
              ),
              const SizedBox(height: 8),
              if (methods.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: EmptyState(
                    icon: Icons.credit_card_off_outlined,
                    title: 'No saved cards',
                    subtitle: 'Add a card to pay faster at checkout',
                  ),
                ),
              for (final method in methods)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.credit_card),
                    title: Row(
                      children: [
                        Flexible(child: Text(method.label)),
                        if (method.isDefault) ...[
                          const SizedBox(width: 8),
                          const Chip(
                            label: Text(
                              'Default',
                              style: TextStyle(fontSize: 10),
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      '${method.holderName} · Expires ${method.expiry}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) async {
                        if (action == 'default') {
                          await _report(
                            await _service.setDefaultPaymentMethod(method.id),
                            'Default card updated',
                          );
                        } else if (action == 'delete') {
                          await _report(
                            await _service.deletePaymentMethod(method.id),
                            'Card removed',
                          );
                        }
                      },
                      itemBuilder: (_) => [
                        if (!method.isDefault)
                          const PopupMenuItem(
                            value: 'default',
                            child: Text('Set as default'),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'For your security only the card brand, last 4 digits, '
                  'holder name and expiry are saved. The full card number '
                  'and CVV are never stored.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Add-card form, also used from checkout. Returns the saved card or null.
Future<PaymentMethodModel?> showPaymentMethodForm(BuildContext context) {
  return showModalBottomSheet<PaymentMethodModel>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _CardForm(),
  );
}

class _CardForm extends StatefulWidget {
  const _CardForm();

  @override
  State<_CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<_CardForm> {
  final _formKey = GlobalKey<FormState>();
  final _holder = TextEditingController();
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  bool _isDefault = false;
  bool _saving = false;

  @override
  void dispose() {
    _holder.dispose();
    _number.dispose();
    _expiry.dispose();
    super.dispose();
  }

  String get _digits => _number.text.replaceAll(RegExp(r'\D'), '');

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final digits = _digits;
    final method = PaymentMethodModel(
      brand: PaymentMethodModel.detectBrand(digits),
      last4: digits.substring(digits.length - 4),
      holderName: _holder.text.trim(),
      expiry: _expiry.text.trim(),
      isDefault: _isDefault,
    );
    final result = await AccountDetailsService().savePaymentMethod(method);
    if (!mounted) return;
    setState(() => _saving = false);
    if (!result.isSuccess) {
      ErrorPresenter.show(context, result);
      return;
    }
    Navigator.of(context).pop(method);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add Card', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _holder,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Cardholder Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    Validators.validateRequired(v, 'Cardholder Name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _number,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                  LengthLimitingTextInputFormatter(23),
                ],
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                validator: (_) => PaymentMethodModel.isValidNumber(_digits)
                    ? null
                    : 'Enter a valid card number',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _expiry,
                keyboardType: TextInputType.datetime,
                inputFormatters: [LengthLimitingTextInputFormatter(5)],
                decoration: const InputDecoration(
                  labelText: 'Expiry (MM/YY)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    PaymentMethodModel.isValidExpiry((v ?? '').trim())
                    ? null
                    : 'Enter a valid, unexpired date (MM/YY)',
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Use as default payment method'),
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                text: 'Save Card',
                icon: Icons.save_outlined,
                isLoading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
