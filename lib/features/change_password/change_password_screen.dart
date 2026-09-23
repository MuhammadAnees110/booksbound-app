import 'package:booksbound_app/providers/user_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _obscure3 = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text("Change Password"), centerTitle: true),
      body: Consumer<UserAuthProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  _passwordField(
                    controller: _currentController,
                    label: "Current Password",
                    obscure: _obscure1,
                    toggle: () => setState(() => _obscure1 = !_obscure1),
                  ),
                  const SizedBox(height: 16),

                  _passwordField(
                    controller: _newController,
                    label: "New Password",
                    obscure: _obscure2,
                    toggle: () => setState(() => _obscure2 = !_obscure2),
                  ),
                  const SizedBox(height: 16),

                  _passwordField(
                    controller: _confirmController,
                    label: "Confirm New Password",
                    obscure: _obscure3,
                    toggle: () => setState(() => _obscure3 = !_obscure3),
                    validator: (value) {
                      if (value != _newController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: provider.isloading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;

                              final messenger = ScaffoldMessenger.of(context);
                              final navigator = Navigator.of(context);

                              final success = await provider.changePassword(
                                currentPassword: _currentController.text.trim(),
                                newPassword: _newController.text.trim(),
                              );

                              if (!mounted) return;

                              if (success) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Password updated successfully",
                                    ),
                                  ),
                                );
                                navigator.pop();
                              } else {
                                messenger.showSnackBar(
                                  SnackBar(content: Text(provider.error)),
                                );
                              }
                            },
                      child: provider.isloading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(
                              "Update Password",
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(color: Colors.white),
                            ),
                    ),
                  ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return "This field is required";
            }
            if (value.length < 6) {
              return "Minimum 6 characters";
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: toggle,
        ),
      ),
    );
  }
}
