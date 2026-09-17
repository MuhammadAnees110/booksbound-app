import 'dart:convert';

import 'package:booksbound_app/widgets/error_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/reviews_provider.dart';

class ReviewsAdminScreen extends StatefulWidget {
  final String bookId;

  const ReviewsAdminScreen({super.key, required this.bookId});

  @override
  State<ReviewsAdminScreen> createState() => _ReviewsAdminScreenState();
}

class _ReviewsAdminScreenState extends State<ReviewsAdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ReviewsProvider>().loadReviews(widget.bookId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReviewsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Reviews')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.reviews.isEmpty
          ? const Center(child: Text('No reviews found'))
          : ListView.builder(
              itemCount: provider.reviews.length,
              itemBuilder: (context, index) {
                final review = provider.reviews[index];
                final avatarUrl = provider.userAvatars[review.userId] ?? '';
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundImage: avatarUrl.isNotEmpty
                          ? MemoryImage(base64Decode(avatarUrl))
                          : null,
                      child: avatarUrl.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(review.userName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(review.comment)],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final reviewsProvider = context.read<ReviewsProvider>();
                        final result = await reviewsProvider.deleteReview(
                          bookId: widget.bookId,
                          review: review.toMap(),
                        );
                        if (!result.isSuccess && context.mounted) {
                          ErrorPresenter.show(context, result);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
