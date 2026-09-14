import 'dart:convert';

import 'package:booksbound_app/features/book_details/widgets/write_review_sheet.dart';
import 'package:booksbound_app/models/book_model.dart';
import 'package:booksbound_app/providers/cart_provider.dart';
import 'package:booksbound_app/providers/ratings_provider.dart';
import 'package:booksbound_app/providers/reviews_provider.dart';
import 'package:booksbound_app/providers/wishlist_provider.dart';
import 'package:booksbound_app/services/analytics_service.dart';
import 'package:booksbound_app/utils/formatters.dart';
import 'package:booksbound_app/utils/haptics.dart';
import 'package:booksbound_app/widgets/cached_image.dart';
import 'package:booksbound_app/widgets/empty_state.dart';
import 'package:booksbound_app/widgets/primary_button.dart';
import 'package:booksbound_app/widgets/ratings.dart';
import 'package:booksbound_app/widgets/skeleton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookDetailsScreen extends StatefulWidget {
  final Book book;
  const BookDetailsScreen({super.key, required this.book});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.logViewItem(
      bookId: widget.book.id,
      title: widget.book.title,
      price: widget.book.price,
    );
    Future.microtask(() {
      if (!mounted) return;
      context.read<RatingsProvider>().getUserRating(widget.book.id);
      context.read<ReviewsProvider>().loadReviews(widget.book.id);
      context.read<WishlistProvider>().loadWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.book.title), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Hero(
                  tag: 'book-cover-${widget.book.id}',
                  child: CachedImage(
                    imageUrl: widget.book.coverUrl,
                    height: 260,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Text(
                  widget.book.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: Consumer<WishlistProvider>(
                    builder: (context, wishlist, _) {
                      final isWishlisted = wishlist.isInWishlist(
                        widget.book.id,
                      );
                      return IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                          size: 25,
                        ),
                        onPressed: () {
                          Haptics.medium();
                          wishlist.toggleWishlist(widget.book.id);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              'by ${widget.book.author}',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  Formatters.formatCurrency(widget.book.price),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    buildRatingStars(rating: widget.book.rating, size: 25),
                    const SizedBox(width: 15),
                    Text(
                      widget.book.rating.toString(),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              'Description',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.book.description,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),

            const SizedBox(height: 15),

            Text(
              'Your Rating',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            Consumer<RatingsProvider>(
              builder: (context, ratingsProvider, _) {
                if (ratingsProvider.isloading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Skeleton(width: 150, height: 28, radius: 6),
                  );
                }

                final userRating = ratingsProvider.userRating;
                final hasRated = ratingsProvider.hasRated(widget.book.id);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            index < userRating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: hasRated
                              ? null
                              : () {
                                  Haptics.selection();
                                  ratingsProvider.rateBook(
                                    widget.book.id,
                                    index + 1,
                                  );
                                },
                        );
                      }),
                    ),

                    if (hasRated)
                      Text(
                        'You already rated this book',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),
            Consumer<ReviewsProvider>(
              builder: (context, reviewsProvider, _) {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  return const SizedBox.shrink();
                }
                final hasReviewed = reviewsProvider.reviews.any(
                  (r) => r.userId == user.uid,
                );
                if (hasReviewed) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'You have reviewed this book',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.rate_review_outlined),
                      label: const Text('Write a Review'),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (_) => WriteReviewSheet(
                            bookId: widget.book.id,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),

            Text(
              'Reviews:',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            Consumer<ReviewsProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return Column(
                    children: List.generate(
                      2,
                      (_) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Skeleton(width: 40, height: 40, radius: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Skeleton(width: 100, height: 14, radius: 4),
                                  SizedBox(height: 6),
                                  Skeleton(
                                    width: double.infinity,
                                    height: 12,
                                    radius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (provider.reviews.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: EmptyState(
                      icon: Icons.rate_review_outlined,
                      title: "No reviews yet",
                      subtitle:
                          "Be the first to share your thoughts on this book!",
                    ),
                  );
                }

                return Column(
                  children: provider.reviews.map((review) {
                    final avatarUrl = provider.userAvatars[review.userId] ?? '';
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: avatarUrl.isNotEmpty
                            ? MemoryImage(base64Decode(avatarUrl))
                            : null,
                        child: avatarUrl.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(
                        review.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(review.comment),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              provider.isLikedBy(review)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              provider.toggleLike(
                                bookId: widget.book.id,
                                review: review,
                              );
                            },
                          ),
                          Text(review.likedBy.length.toString()),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 32),

            PrimaryButton(
              text: 'Add to Cart',
              icon: Icons.shopping_bag_outlined,
              onPressed: () {
                context.read<CartProvider>().addToCart(widget.book);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Added to Cart")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
