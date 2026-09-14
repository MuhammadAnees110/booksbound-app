import 'package:booksbound_app/models/book_model.dart';
import 'package:booksbound_app/models/category_model.dart';
import 'package:booksbound_app/routes/app_routes.dart';
import 'package:booksbound_app/services/books_service.dart';
import 'package:booksbound_app/utils/formatters.dart';
import 'package:booksbound_app/utils/haptics.dart';
import 'package:booksbound_app/widgets/book_card_skeleton.dart';
import 'package:booksbound_app/widgets/empty_state.dart';
import 'package:booksbound_app/widgets/ratings.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';

class CategoryBooksScreen extends StatelessWidget {
  final CategoryModel category;

  const CategoryBooksScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final booksService = BooksService();

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (category.imageUrl.isNotEmpty)
            Hero(
              tag: 'category-${category.id}',
              child: SizedBox(
                height: 110,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      category.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.blueGrey.shade100,
                        child: const Icon(Icons.menu_book, size: 40),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                    if (category.description.isNotEmpty)
                      Positioned(
                        bottom: 10,
                        left: 16,
                        right: 16,
                        child: Text(
                          category.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: FutureBuilder<List<Book>>(
              future: booksService.getBooksByGenre(category.name),
              builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (_, __) => const BookListTileSkeleton(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading books',
                textAlign: TextAlign.center,
              ),
            );
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
            return EmptyState(
              icon: Icons.menu_book_outlined,
              title: "No books found",
              subtitle: 'No books found in "${category.name}"',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final book = books[index];
              return InkWell(
                onTap: () {
                  Haptics.light();
                  Navigator.of(context, rootNavigator: true).pushNamed(
                    AppRoutes.bookDetails,
                    arguments: book,
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          book.coverUrl,
                          width: 60,
                          height: 85,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'images/cover-error.png',
                            width: 60,
                            height: 85,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book.author,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                buildRatingStars(rating: book.rating, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  Formatters.formatCurrency(book.price),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .animate(delay: ((index % 6) * 50).ms)
                  .fadeIn(duration: 250.ms)
                  .slideY(begin: 0.1);
            },
          );
        },
      ),
    ),
  ],
),
);
}
}
