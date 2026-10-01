import 'package:booksbound_app/models/book_model.dart';
import 'package:booksbound_app/providers/book_provider.dart';
import 'package:booksbound_app/routes/app_routes.dart';
import 'package:booksbound_app/utils/formatters.dart';
import 'package:booksbound_app/widgets/cached_image.dart';
import 'package:booksbound_app/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Browse the catalog by author.
class AuthorsScreen extends StatefulWidget {
  const AuthorsScreen({super.key});

  @override
  State<AuthorsScreen> createState() => _AuthorsScreenState();
}

class _AuthorsScreenState extends State<AuthorsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final authors = context
        .watch<BookProvider>()
        .authors
        .entries
        .where((e) => e.key.toLowerCase().contains(_query))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Authors'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search authors',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: authors.isEmpty
                ? const EmptyState(
                    icon: Icons.person_search_outlined,
                    title: 'No authors found',
                    subtitle: 'Try a different name',
                  )
                : ListView.separated(
                    itemCount: authors.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final entry = authors[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(entry.key.characters.first.toUpperCase()),
                        ),
                        title: Text(entry.key),
                        subtitle: Text(
                          '${entry.value} book${entry.value == 1 ? '' : 's'}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.authorBooks,
                          arguments: entry.key,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// All books by one author.
class AuthorBooksScreen extends StatelessWidget {
  final String author;
  const AuthorBooksScreen({super.key, required this.author});

  @override
  Widget build(BuildContext context) {
    final List<Book> books = context.watch<BookProvider>().booksByAuthor(
      author,
    );

    return Scaffold(
      appBar: AppBar(title: Text(author), centerTitle: true),
      body: books.isEmpty
          ? const EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'No books yet',
              subtitle: 'This author has no books in the catalog',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: books.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final book = books[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: CachedImage(
                      imageUrl: book.coverUrl,
                      width: 48,
                      height: 72,
                      borderRadius: 4,
                    ),
                    title: Text(book.title),
                    subtitle: Text(
                      '${book.genre} · ★ ${book.rating.toStringAsFixed(1)}',
                    ),
                    trailing: Text(Formatters.formatCurrency(book.price)),
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.bookDetails, arguments: book),
                  ),
                );
              },
            ),
    );
  }
}
