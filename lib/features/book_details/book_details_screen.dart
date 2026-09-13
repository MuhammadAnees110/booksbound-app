import 'dart:convert';

import 'package:booksbound_app/models/book_model.dart';
import 'package:booksbound_app/providers/cart_provider.dart';
import 'package:booksbound_app/providers/ratings_provider.dart';
import 'package:booksbound_app/providers/reviews_provider.dart';
import 'package:booksbound_app/providers/wishlist_provider.dart';
import 'package:booksbound_app/utils/formatters.dart';
import 'package:booksbound_app/widgets/ratings.dart';
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
    Future.microtask(() {
      if (!mounted) return;
      context.read<RatingsProvider>().getUserRating(widget.book.id);
      context.read<ReviewsProvider>().loadReviews(widget.book.id);
      context.read<WishlistProvider>().loadWishlist();
    });
  }

  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmittingReview = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
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
                child: Image.network(
                  widget.book.coverUrl,
                  height: 260,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Image.asset('images/cover-error.png', height: 260);
                  },
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
                  return const CircularProgressIndicator();
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

            const SizedBox(height: 24),

            Text(
              'Write a review',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Share your thoughts about this book...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _isSubmittingReview
                    ? null
                    : () async {
                        final text = _reviewController.text.trim();
                        if (text.isEmpty) return;

                        setState(() => _isSubmittingReview = true);

                        await context.read<ReviewsProvider>().addReview(
                          bookId: widget.book.id,
                          comment: text,
                        );

                        if (!context.mounted) return;

                        _reviewController.clear();
                        setState(() => _isSubmittingReview = false);
                      },
                child: _isSubmittingReview
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Post Review'),
              ),
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
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.reviews.isEmpty) {
                  return const Text("No reviews yet");
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

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  context.read<CartProvider>().addToCart(widget.book);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Added to Cart")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
