import 'package:booksbound_app/models/book_model.dart';
import 'package:booksbound_app/models/category_model.dart';
import 'package:booksbound_app/routes/app_routes.dart';
import 'package:booksbound_app/services/books_service.dart';
import 'package:booksbound_app/utils/formatters.dart';
import 'package:booksbound_app/utils/haptics.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:booksbound_app/widgets/book_card_skeleton.dart';
import 'package:booksbound_app/widgets/cached_image.dart';
import 'package:booksbound_app/widgets/empty_state.dart';
import 'package:booksbound_app/widgets/ratings.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';

class CategoryBooksScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryBooksScreen({super.key, required this.category});

  @override
  State<CategoryBooksScreen> createState() => _CategoryBooksScreenState();
}

class _CategoryBooksScreenState extends State<CategoryBooksScreen> {
  late final Future<Result<List<Book>>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = BooksService().getBooksByGenre(widget.category.name);
  }

  @override
  Widget build(BuildContext context) {
    final hasBannerImage = widget.category.imageUrl.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name), centerTitle: true),
      body: Column(
        children: [
          if (hasBannerImage)
            Hero(
              tag: 'category-${widget.category.id}',
              child: SizedBox(
                height: 110,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedImage(imageUrl: widget.category.imageUrl, fit: BoxFit.cover),
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
                    Positioned(
                      bottom: 10,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.category.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (widget.category.description.isNotEmpty)
                            Text(
                              widget.category.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 110,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 32,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category.name,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.category.description.isNotEmpty)
                          Text(
                            widget.category.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: FutureBuilder<Result<List<Book>>>(
              future: _booksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 5,
                    itemBuilder: (_, _) => const BookListTileSkeleton(),
                  );
                }

                final result = snapshot.data;
                if (snapshot.hasError ||
                    (result != null && !result.isSuccess)) {
                  return const Center(
                    child: Text(
                      'Error loading books',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final books = result?.data ?? [];

                if (books.isEmpty) {
                  return EmptyState(
                    icon: Icons.menu_book_outlined,
                    title: "No books found",
                    subtitle: 'No books found in "${widget.category.name}"',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: books.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return InkWell(
                          onTap: () {
                            Haptics.light();
                            Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.bookDetails, arguments: book);
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
                                  child: CachedImage(
                                    imageUrl: book.coverUrl,
                                    width: 60,
                                    height: 85,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          buildRatingStars(
                                            rating: book.rating,
                                            size: 14,
                                          ),
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
                                            Formatters.formatCurrency(
                                              book.price,
                                            ),
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
