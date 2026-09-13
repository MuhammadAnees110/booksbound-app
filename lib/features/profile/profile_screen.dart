import 'dart:convert';

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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), centerTitle: true),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isloading) {
            return const Center(child: CircularProgressIndicator());
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
                      child: GestureDetector(
                        onTap: provider.changeProfilePicture,
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
                              child: StreamBuilder<List<OrderModel>>(
                                stream: OrderService().getUserOrders(uid),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return const Center(
                                        child: Text('No orders yet.'));
                                  }
                                  final orders = snapshot.data!;
                                  return ListView.separated(
                                    controller: scrollController,
                                    itemCount: orders.length,
                                    separatorBuilder: (_, __) =>
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
                      leading: Icon(
                        themeProvider.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                      ),
                      title: const Text("Dark Mode"),
                      trailing: Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (_) {
                          themeProvider.toggleTheme();
                        },
                      ),
                    );
                  },
                ),
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
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
