import 'package:booksbound_app/models/order_model.dart';
import 'package:booksbound_app/providers/book_provider.dart';
import 'package:booksbound_app/providers/cart_provider.dart';
import 'package:booksbound_app/providers/ratings_provider.dart';
import 'package:booksbound_app/providers/reviews_provider.dart';
import 'package:booksbound_app/providers/theme_provider.dart';
import 'package:booksbound_app/providers/user_provider.dart';
import 'package:booksbound_app/providers/user_auth_provider.dart';
import 'package:booksbound_app/providers/wishlist_provider.dart';
import 'package:booksbound_app/routes/app_routes.dart';
import 'package:booksbound_app/services/order_service.dart';
import 'package:booksbound_app/utils/formatters.dart';
import 'package:booksbound_app/utils/haptics.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:booksbound_app/widgets/empty_state.dart';
import 'package:booksbound_app/widgets/error_snackbar.dart';
import 'package:booksbound_app/widgets/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ProfileProvider>().getUserData();
    });
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), centerTitle: true),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isloading) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Skeleton(width: 100, height: 100, radius: 50),
                  SizedBox(height: 16),
                  Skeleton(width: 140, height: 20, radius: 4),
                  SizedBox(height: 8),
                  Skeleton(width: 180, height: 14, radius: 4),
                  SizedBox(height: 24),
                  Skeleton(width: double.infinity, height: 50, radius: 12),
                  SizedBox(height: 12),
                  Skeleton(width: double.infinity, height: 50, radius: 12),
                  SizedBox(height: 12),
                  Skeleton(width: double.infinity, height: 50, radius: 12),
                ],
              ),
            );
          }

          if (provider.error.isNotEmpty) {
            return Center(child: Text(provider.error));
          }

          final userData = provider.userData;
          if (userData == null) {
            return const Center(child: Text("No user data"));
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: userData['photoUrl'] != null
                          ? MemoryImage(base64Decode(userData['photoUrl']))
                          : null,
                      child: userData['photoUrl'] == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Semantics(
                        label: 'Change profile picture',
                        button: true,
                        child: GestureDetector(
                          onTap: () async {
                            final result =
                                await provider.changeProfilePicture();
                            if (!result.isSuccess && context.mounted) {
                              ErrorPresenter.show(context, result);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Name
                Text(
                  userData['name'] ?? "No Name",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                // Email
                Text(
                  userData["email"] ?? "No Email",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // Profile Options
                Expanded(
                  child: ListView(
                    children: [
                      _profileTile(
                        icon: Icons.edit,
                        title: "Edit Profile",
                        onTap: () {
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushNamed(appRoutes.editProfile);
                        },
                      ),
                      _profileTile(
                        icon: Icons.lock,
                        title: "Change Password",
                        onTap: () {
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushNamed(appRoutes.changePassword);
                        },
                      ),
                      _profileTile(
                        icon: Icons.shopping_bag_outlined,
                        title: "My Orders",
                        onTap: () {
                          final uid =
                              context.read<UserAuthProvider>().user?.uid ?? '';
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (_) => DraggableScrollableSheet(
                              expand: false,
                              initialChildSize: 0.6,
                              maxChildSize: 0.95,
                              builder: (_, scrollController) => Column(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      'Order History',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: StreamBuilder<Result<List<OrderModel>>>(
                                      stream: OrderService().getUserOrders(uid),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return ListView.separated(
                                            controller: scrollController,
                                            itemCount: 4,
                                            separatorBuilder: (_, _) =>
                                                const SizedBox(height: 8),
                                            itemBuilder: (_, _) =>
                                                const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16.0,
                                                  vertical: 8.0),
                                              child: Skeleton(
                                                width: double.infinity,
                                                height: 50,
                                                radius: 8,
                                              ),
                                            ),
                                          );
                                        }
                                        final result = snapshot.data;
                                        if (result == null ||
                                            !result.isSuccess ||
                                            result.data!.isEmpty) {
                                          return const EmptyState(
                                            icon: Icons.inventory_2_outlined,
                                            title: "No orders yet",
                                            subtitle:
                                                "Your purchase history will appear here",
                                          );
                                        }
                                        final orders = result.data!;
                                        return ListView.separated(
                                          controller: scrollController,
                                          itemCount: orders.length,
                                          separatorBuilder: (_, _) =>
                                              const Divider(height: 1),
                                          itemBuilder: (context, index) {
                                            final order = orders[index];
                                            return ListTile(
                                              leading: const Icon(
                                                  Icons.receipt_long_outlined),
                                              title: Text(
                                                '${order.items.length} item(s) — ${Formatters.formatCurrency(order.totalAmount)}',
                                              ),
                                              subtitle: Text(
                                                Formatters.formatDate(
                                                    order.createdAt),
                                              ),
                                              trailing: Chip(
                                                label: Text(
                                                  order.status
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                      fontSize: 10),
                                                ),
                                                backgroundColor:
                                                    order.status == 'delivered'
                                                        ? Colors.green[100]
                                                        : Colors.orange[100],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, _) {
                          return ListTile(
                            leading: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              transitionBuilder: (child, anim) =>
                                  RotationTransition(
                                turns: anim,
                                child: FadeTransition(
                                  opacity: anim,
                                  child: child,
                                ),
                              ),
                              child: Icon(
                                themeProvider.isDarkMode
                                    ? Icons.dark_mode
                                    : Icons.light_mode,
                                key: ValueKey(themeProvider.isDarkMode),
                              ),
                            ),
                            title: const Text("Dark Mode"),
                            trailing: Switch(
                              value: themeProvider.isDarkMode,
                              onChanged: (_) {
                                Haptics.light();
                                themeProvider.toggleTheme();
                              },
                            ),
                          );
                        },
                      ),

                      // ── Legal Section ─────────────────────────────────────
                      const Divider(),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Text(
                          'Legal',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: const Text("Privacy Policy"),
                        trailing: const Icon(Icons.open_in_new, size: 16),
                        onTap: () => _openUrl(
                            'https://muhammadanees.github.io/booksbound-legal/privacy_policy.html'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: const Text("Terms of Service"),
                        trailing: const Icon(Icons.open_in_new, size: 16),
                        onTap: () => _openUrl(
                            'https://muhammadanees.github.io/booksbound-legal/terms_of_service.html'),
                      ),

                      // ── Account Actions ───────────────────────────────────
                      const Divider(),
                      _profileTile(
                        icon: Icons.logout,
                        title: "Logout",
                        onTap: () async {
                          final navigator = Navigator.of(
                            context,
                            rootNavigator: true,
                          );

                          // Clear local UI providers synchronously using context
                          context.read<ProfileProvider>().clear();
                          context.read<BookProvider>().clear();
                          context.read<CartProvider>().clear();
                          context.read<RatingsProvider>().clear();
                          context.read<ReviewsProvider>().clear();
                          context.read<WishlistProvider>().clear();

                          // Perform logout without passing context
                          await context.read<UserAuthProvider>().logout();

                          if (!mounted) return;

                          navigator.pushReplacementNamed(appRoutes.login);
                        },
                      ),

                      // Delete Account (red)
                      ListTile(
                        leading: const Icon(Icons.delete_forever,
                            color: Colors.red),
                        title: const Text(
                          "Delete Account",
                          style: TextStyle(color: Colors.red),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.red),
                        onTap: () async {
                          final nav = Navigator.of(context, rootNavigator: true);
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Account?'),
                              content: const Text(
                                'Are you sure? This will permanently delete your account and all data. This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.red),
                                  onPressed: () =>
                                      Navigator.of(ctx).pop(true),
                                  child: const Text('Delete Account'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true && mounted) {
                            nav.pushNamed(appRoutes.deleteAccount);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: title,
      button: true,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
