import 'package:booksbound_app/providers/user_provider.dart';
import 'package:booksbound_app/widgets/error_snackbar.dart';
import 'package:booksbound_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ProfileProvider>().getUserData();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          final userData = profileProvider.userData;

          if (userData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!_isInitialized) {
            _nameController.text = userData["name"] ?? '';
            _isInitialized = true;
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Avatar
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            UserAvatar(
                              photoUrl: userData['photoUrl'] as String?,
                              radius: 55,
                            ),
                            GestureDetector(
                              onTap: profileProvider.isloading
                                  ? null
                                  : profileProvider.changeProfilePicture,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: "Name",
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter a Name";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: profileProvider.isloading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;

                            final messenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);

                            final result = await profileProvider.saveProfile(
                              _nameController.text.trim(),
                              userData["photoUrl"],
                            );

                            if (!context.mounted) return;

                            if (!result.isSuccess) {
                              ErrorPresenter.show(context, result);
                              return;
                            }

                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text("Profile saved successfully"),
                              ),
                            );
                            navigator.pop();
                          },
                    child: profileProvider.isloading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
