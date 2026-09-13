import 'package:booksbound_app/providers/wishlist_provider.dart';
import 'package:booksbound_app/widgets/ratings.dart';
import 'package:booksbound_app/widgets/sort_sheet.dart';
import 'package:booksbound_app/models/book_model.dart';
import 'package:booksbound_app/providers/book_provider.dart';
import 'package:booksbound_app/providers/category_provider.dart';
import 'package:booksbound_app/routes/app_routes.dart';
import 'package:booksbound_app/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<BookProvider>().loadBooks();
      context.read<WishlistProvider>().loadWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    if (bookProvider.isloading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildCategoriesRow(context),
                const SizedBox(height: 15),
                _buildBookCarousel(bookProvider.bestsellers, 'Bestsellers'),
                const SizedBox(height: 20),
                _buildBookCarousel(bookProvider.newArrivals, 'New Arrivals'),
                const SizedBox(height: 20),
                _buildBookGrid(bookProvider.visibleBooks, 'All Books', context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesRow(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.categories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pushNamed(
                    appRoutes.categories,
                  );
                },
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return ActionChip(
                avatar: const Icon(Icons.menu_book, size: 16),
                label: Text(cat.name),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pushNamed(
                    appRoutes.categoryBooks,
                    arguments: cat,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookCarousel(List<Book> books, String title) {
    if (books.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];

              return InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamed(appRoutes.bookDetails, arguments: book);
                },
                child: Container(
                  width: 150,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                book.coverUrl,
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return Image.asset(
                                    'images/cover-error.png',
                                    height: 140,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: Consumer<WishlistProvider>(
                                  builder: (context, wishlist, _) {
                                    final isWishlisted = wishlist.isInWishlist(
                                      book.id,
                                    );
                                    return IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: Icon(
                                        isWishlisted
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        wishlist.toggleWishlist(book.id);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          book.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        buildRatingStars(rating: book.rating),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookGrid(List<Book> books, String title, BuildContext context) {
    if (books.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: () => SortSheet().showSortSheet(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamed(appRoutes.bookDetails, arguments: book);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  book.coverUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return Image.asset(
                                      'images/cover-error.png',
                                      fit: BoxFit.fitWidth,
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: Consumer<WishlistProvider>(
                                    builder: (context, wishlist, _) {
                                      final isWishlisted = wishlist
                                          .isInWishlist(book.id);
                                      return IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: Icon(
                                          isWishlisted
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: Colors.red,
                                          size: 25,
                                        ),
                                        onPressed: () {
                                          wishlist.toggleWishlist(book.id);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          book.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        buildRatingStars(rating: book.rating),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.formatCurrency(book.price),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
