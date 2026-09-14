import 'package:booksbound_app/models/book_model.dart';
import 'package:booksbound_app/providers/book_provider.dart';
import 'package:booksbound_app/providers/cart_provider.dart';
import 'package:booksbound_app/providers/wishlist_provider.dart';
import 'package:booksbound_app/routes/app_routes.dart';
import 'package:booksbound_app/services/analytics_service.dart';
import 'package:booksbound_app/utils/haptics.dart';
import 'package:booksbound_app/widgets/book_card_skeleton.dart';
import 'package:booksbound_app/widgets/cached_image.dart';
import 'package:booksbound_app/widgets/empty_state.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  static Future<void> addToWishlist(BuildContext context, Book book) async {
    await context.read<WishlistProvider>().toggleWishlist(book.id);
    await AnalyticsService.logWishlistAdd(book.id);
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final booksProvider = Provider.of<BookProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wishlist"),
        centerTitle: true,
        actions: [
          if (wishlist.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.shopping_cart_checkout),
              tooltip: "Move All to Cart",
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Move All to Cart'),
                    content: const Text(
                      'Do you want to move all items from your wishlist into your shopping cart?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Move All'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  Haptics.medium();
                  final cartProvider = context.read<CartProvider>();
                  final matchingBooks = booksProvider.visibleBooks
                      .where((b) => wishlist.items.contains(b.id))
                      .toList();

                  int count = 0;
                  for (final book in matchingBooks) {
                    cartProvider.addToCart(book);
                    count++;
                  }

                  // Clear wishlist
                  for (final book in matchingBooks) {
                    await wishlist.removeFromWishlist(book.id);
                  }

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$count item(s) moved to cart'),
                      backgroundColor: Colors.green,
                      action: SnackBarAction(
                        label: 'View Cart',
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                }
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          Haptics.light();
          await Future.wait([
            wishlist.loadWishlist(),
            booksProvider.loadBooks(),
          ]);
        },
        child: wishlist.isLoading
            ? ListView.builder(
                itemCount: 5,
                itemBuilder: (_, _) => const BookListTileSkeleton(),
              )
            : wishlist.items.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: EmptyState(
                        icon: Icons.favorite_border,
                        title: "No favorites yet",
                        subtitle: "Tap the heart on any book to save it here",
                        actionText: "Discover Books",
                        onAction: () {
                          Haptics.light();
                          Navigator.of(context, rootNavigator: true)
                              .pushNamed(AppRoutes.categories);
                        },
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
              itemCount: wishlist.items.length,
              itemBuilder: (context, index) {
                final books = booksProvider.visibleBooks
                    .where((b) => wishlist.items.contains(b.id))
                    .toList();
                final book = books[index];
                return Semantics(
                  label: '${book.title} by ${book.author}',
                  button: true,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedImage(
                        imageUrl: book.coverUrl,
                        width: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(book.title),
                    subtitle: Text(book.author),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Remove from wishlist',
                      onPressed: () async {
                        Haptics.heavy();
                        await wishlist.removeFromWishlist(book.id);
                      },
                    ),
                    onTap: () {
                      Haptics.light();
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushNamed(appRoutes.bookDetails, arguments: book);
                    },
                  ),
                )
                    .animate(delay: ((index % 6) * 50).ms)
                    .fadeIn(duration: 250.ms)
                    .slideY(begin: 0.1);
              },
            ),
      ),
    );
  }
}
