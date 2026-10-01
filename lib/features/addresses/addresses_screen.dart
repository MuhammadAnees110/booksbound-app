import 'package:booksbound_app/models/address_model.dart';
import 'package:booksbound_app/services/account_details_service.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:booksbound_app/utils/validators.dart';
import 'package:booksbound_app/widgets/empty_state.dart';
import 'package:booksbound_app/widgets/error_snackbar.dart';
import 'package:booksbound_app/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final _service = AccountDetailsService();
  late final Stream<List<AddressModel>> _stream = _service.watchAddresses();

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
      appBar: AppBar(
        title: const Text('Shipping Addresses'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add_address_button'),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add Address'),
        onPressed: () => showAddressForm(context),
      ),
      body: StreamBuilder<List<AddressModel>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const EmptyState(
              icon: Icons.error_outline,
              title: 'Unable to load addresses',
              subtitle: 'Please try again later',
            );
          }
          final addresses = snapshot.data ?? [];
          if (addresses.isEmpty) {
            return const EmptyState(
              icon: Icons.location_off_outlined,
              title: 'No saved addresses',
              subtitle: 'Add an address to check out faster',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
            itemCount: addresses.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final address = addresses[index];
              return Card(
                child: ListTile(
                  leading: Icon(
                    address.isDefault ? Icons.home : Icons.location_on_outlined,
                  ),
                  title: Row(
                    children: [
                      Flexible(child: Text(address.label)),
                      if (address.isDefault) ...[
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
                  subtitle: Text(address.formatted),
                  isThreeLine: true,
                  onTap: () => showAddressForm(context, existing: address),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) async {
                      if (action == 'default') {
                        await _report(
                          await _service.setDefaultAddress(address.id),
                          'Default address updated',
                        );
                      } else if (action == 'delete') {
                        await _report(
                          await _service.deleteAddress(address.id),
                          'Address removed',
                        );
                      }
                    },
                    itemBuilder: (_) => [
                      if (!address.isDefault)
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
              );
            },
          );
        },
      ),
    );
  }
}

/// Add/edit form, also used from checkout. Returns the saved address or null.
Future<AddressModel?> showAddressForm(
  BuildContext context, {
  AddressModel? existing,
}) {
  return showModalBottomSheet<AddressModel>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _AddressForm(existing: existing),
  );
}

class _AddressForm extends StatefulWidget {
  final AddressModel? existing;
  const _AddressForm({this.existing});

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  final _formKey = GlobalKey<FormState>();
  late final _label = TextEditingController(
    text: widget.existing?.label ?? 'Home',
  );
  late final _name = TextEditingController(text: widget.existing?.fullName);
  late final _phone = TextEditingController(text: widget.existing?.phone);
  late final _street = TextEditingController(text: widget.existing?.street);
  late final _city = TextEditingController(text: widget.existing?.city);
  late final _postal = TextEditingController(text: widget.existing?.postalCode);
  late final _country = TextEditingController(
    text: widget.existing?.country ?? 'Pakistan',
  );
  late bool _isDefault = widget.existing?.isDefault ?? false;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _label,
      _name,
      _phone,
      _street,
      _city,
      _postal,
      _country,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final address = AddressModel(
      id: widget.existing?.id ?? '',
      label: _label.text.trim(),
      fullName: _name.text.trim(),
      phone: _phone.text.trim(),
      street: _street.text.trim(),
      city: _city.text.trim(),
      postalCode: _postal.text.trim(),
      country: _country.text.trim(),
      isDefault: _isDefault,
    );
    final result = await AccountDetailsService().saveAddress(address);
    if (!mounted) return;
    setState(() => _saving = false);
    if (!result.isSuccess) {
      ErrorPresenter.show(context, result);
      return;
    }
    Navigator.of(context).pop(address);
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboard,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (v) => Validators.validateRequired(v, label)
            : null,
      ),
    );
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
              Text(
                widget.existing == null ? 'Add Address' : 'Edit Address',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _field(_label, 'Label (e.g. Home, Work)'),
              _field(_name, 'Full Name'),
              _field(_phone, 'Phone', keyboard: TextInputType.phone),
              _field(_street, 'Street Address'),
              Row(
                children: [
                  Expanded(child: _field(_city, 'City')),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      _postal,
                      'Postal Code',
                      keyboard: TextInputType.number,
                      required: false,
                    ),
                  ),
                ],
              ),
              _field(_country, 'Country'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Use as default address'),
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                text: 'Save Address',
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
