import 'package:booksbound_app/routes/app_routes.dart';
import 'package:booksbound_app/services/user_service.dart';
import 'package:booksbound_app/utils/haptics.dart';
import 'package:booksbound_app/widgets/error_snackbar.dart';
import 'package:flutter/material.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _confirmController = TextEditingController();
  bool _isLoading = false;

  bool get _canDelete => _confirmController.text.trim() == 'DELETE';

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (!_canDelete) return;

    Haptics.warning();
    setState(() => _isLoading = true);

    final result = await ProfileService().deleteAccount();
    if (!mounted) return;
    if (!result.isSuccess) {
      ErrorPresenter.show(context, result);
      setState(() => _isLoading = false);
      return;
    }
    Navigator.of(context, rootNavigator: true)
        .pushNamedAndRemoveUntil(appRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Delete Account'),
        centerTitle: true,
        foregroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.red),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            // Warning icon
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 72,
            ),
            const SizedBox(height: 16),

            // Warning title
            const Text(
              'Delete Your Account?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),

            // Warning message
            const Text(
              'This action is permanent and cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 24),

            // What will be deleted
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'The following data will be permanently deleted:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  _DeleteItem('Your profile and account credentials'),
                  _DeleteItem('Your cart and wishlist'),
                  _DeleteItem('Your reviews and ratings (anonymized)'),
                  _DeleteItem('Your order history (anonymized for records)'),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Confirmation field
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Type DELETE to confirm:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'DELETE',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Delete button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _canDelete && !_isLoading ? _deleteAccount : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  disabledBackgroundColor: Colors.red.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Delete My Account Permanently',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Haptics.light();
                        Navigator.of(context).pop();
                      },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteItem extends StatelessWidget {
  final String text;
  const _DeleteItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
