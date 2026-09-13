import 'package:booksbound_app/models/book_model.dart';
import 'package:booksbound_app/models/category_model.dart';
import 'package:booksbound_app/routes/app_routes.dart';
import 'package:booksbound_app/services/books_service.dart';
import 'package:booksbound_app/utils/formatters.dart';
import 'package:booksbound_app/widgets/ratings.dart';
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
      body: FutureBuilder<List<Book>>(
        future: booksService.getBooksByGenre(category.name),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading books: ',
                textAlign: TextAlign.center,
              ),
            );
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No books found in ""',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
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
              );
            },
          );
        },
      ),
    );
  }
}
