import 'package:booksbound_app/providers/book_provider.dart';
import 'package:booksbound_app/providers/wishlist_provider.dart';
import 'package:booksbound_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final booksProvider = Provider.of<BookProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Wishlist"), centerTitle: true),
      body: wishlist.isLoading
          ? const Center(child: CircularProgressIndicator())
          : wishlist.items.isEmpty
          ? const Center(child: Text("Your wishlist is empty"))
          : ListView.builder(
              itemCount: wishlist.items.length,
              itemBuilder: (context, index) {
                final books = booksProvider.visibleBooks
                    .where((b) => wishlist.items.contains(b.id))
                    .toList();
                final book = books[index];
                return ListTile(
                  leading: Image.network(
                    book.coverUrl,
                    width: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Image.asset(
                        'images/cover-error.png',
                        width: 50,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  title: Text(book.title),
                  subtitle: Text(book.author),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await wishlist.removeFromWishlist(book.id);
                    },
                  ),
                  onTap: () {
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushNamed(appRoutes.bookDetails, arguments: book);
                  },
                );
              },
            ),
    );
  }
}
