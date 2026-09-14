import 'package:booksbound_app/models/book_model.dart';
import 'package:booksbound_app/providers/book_provider.dart';
import 'package:booksbound_app/routes/app_routes.dart';
import 'package:booksbound_app/services/analytics_service.dart';
import 'package:booksbound_app/utils/formatters.dart';
import 'package:booksbound_app/utils/haptics.dart';
import 'package:booksbound_app/widgets/book_card_skeleton.dart';
import 'package:booksbound_app/widgets/cached_image.dart';
import 'package:booksbound_app/widgets/empty_state.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = context.watch<BookProvider>();

    final List<Book> results = bookProvider.search(_query);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _query = value.trim();
                });
              },
              onSubmitted: (value) {
                final query = value.trim();
                if (query.isNotEmpty) {
                  AnalyticsService.logSearch(query);
                }
              },
              decoration: InputDecoration(
                hintText: "Search Title, Author, ISBN no",
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(),
                ),
              ),
            ),
          ),

          /// 📚 Content
          Expanded(
            child: bookProvider.isloading
                ? ListView.builder(
                    itemCount: 6,
                    itemBuilder: (_, _) => const BookListTileSkeleton(),
                  )
                : _query.isEmpty
                    ? _buildEmptyState()
                    : results.isEmpty
                        ? _buildNoResults()
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final book = results[index];
                      return Semantics(
                        label: '${book.title} by ${book.author}, ${Formatters.formatCurrency(book.price)}',
                        button: true,
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedImage(
                              imageUrl: book.coverUrl,
                              width: 45,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(book.title),
                          subtitle: Text(book.author),
                          trailing: Text(
                            Formatters.formatCurrency(book.price),
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
        ],
      ),
    );
  }

  /// 💤 Initial Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('images/bookshelf.png', height: 120),
          const SizedBox(height: 16),
          Text(
            'Try searching to get started',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return const EmptyState(
      icon: Icons.search_off_rounded,
      title: "No books found",
      subtitle: "Try a different keyword or category",
    );
  }
}
