import 'package:booksbound_app/features/admin/analytics/providers/admin_analytics_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminAnalyticsProvider>().loadAnalytics();
    });
  }

  Widget _statCard(String title, int value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Analytics')),
      body: Consumer<AdminAnalyticsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error.isNotEmpty) {
            return Center(child: Text(provider.error));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _statCard(
                  'Total Users',
                  provider.totalUsers,
                  Icons.people,
                  Colors.blue,
                ),
                _statCard(
                  'Blocked Users',
                  provider.blockedUsers,
                  Icons.block,
                  Colors.red,
                ),
                _statCard(
                  'Total Books',
                  provider.totalBooks,
                  Icons.book,
                  Colors.green,
                ),
                _statCard(
                  'Bestsellers',
                  provider.bestsellerBooks,
                  Icons.star,
                  Colors.orange,
                ),
                _statCard(
                  'Total Reviews',
                  provider.totalReviews,
                  Icons.reviews,
                  Colors.purple,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
