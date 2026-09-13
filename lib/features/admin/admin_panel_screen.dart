import 'package:booksbound_app/providers/user_provider.dart';
import 'package:booksbound_app/routes/app_routes.dart';
import 'package:booksbound_app/widgets/admin_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<ProfileProvider>();

    if (!role.isAdmin) {
      return const Scaffold(body: Center(child: Text("Access Denied")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            AdminCard(
              icon: Icons.book,
              title: "Manage Books",
              onTap: () {
                Navigator.of(context).pushNamed(appRoutes.manageBooks);
              },
            ),
            AdminCard(
              icon: Icons.local_shipping,
              title: "Manage Orders",
              onTap: () {
                Navigator.of(context).pushNamed(appRoutes.manageOrders);
              },
            ),
            AdminCard(
              icon: Icons.rate_review,
              title: "Reviews",
              onTap: () {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamed(appRoutes.manageReviewsBooks);
              },
            ),
            AdminCard(
              icon: Icons.people,
              title: "Users",
              onTap: () {
                Navigator.of(context).pushNamed(appRoutes.manageUsers);
              },
            ),
            AdminCard(
              icon: Icons.analytics,
              title: "Analytics",
              onTap: () {
                Navigator.of(context).pushNamed(appRoutes.analytics);
              },
            ),
          ],
        ),
      ),
    );
  }
}