import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:booksbound_app/providers/book_provider.dart';
import 'package:booksbound_app/models/book_model.dart';
import 'package:booksbound_app/utils/formatters.dart';
import 'package:booksbound_app/widgets/book_form_dialog.dart';
import 'package:booksbound_app/widgets/cached_image.dart';
import 'package:booksbound_app/widgets/error_snackbar.dart';

class ManageBooksScreen extends StatefulWidget {
  const ManageBooksScreen({super.key});

  @override
  State<ManageBooksScreen> createState() => _ManageBooksScreenState();
}

class _ManageBooksScreenState extends State<ManageBooksScreen> {
  late BookProvider _bookProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bookProvider = context.read<BookProvider>();
      _bookProvider.loadBooks();
    });
  }

  void _showAddBookDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => BookFormDialog(
        onSubmit: (book, XFile? imageFile) async {
          final result = await _bookProvider.addBook(
            book,
            imageFile: imageFile,
          );
          if (result.isSuccess && dialogContext.mounted) {
            Navigator.pop(dialogContext);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Book added successfully')),
              );
            }
          } else if (!result.isSuccess && mounted) {
            ErrorPresenter.show(context, result);
          }
        },
      ),
    );
  }

  void _showEditBookDialog(Book book) {
    showDialog(
      context: context,
      builder: (dialogContext) => BookFormDialog(
        book: book,
        onSubmit: (updatedBook, XFile? imageFile) async {
          final result = await _bookProvider.updateBook(
            book.id,
            updatedBook,
            imageFile: imageFile,
          );
          if (result.isSuccess && dialogContext.mounted) {
            Navigator.pop(dialogContext);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Book updated successfully')),
              );
            }
          } else if (!result.isSuccess && mounted) {
            ErrorPresenter.show(context, result);
          }
        },
      ),
    );
  }

  Future<void> _deleteBook(Book book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Are you sure you want to delete "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _bookProvider.deleteBook(book.id);
      if (result.isSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book deleted successfully')),
        );
      } else if (!result.isSuccess && mounted) {
        ErrorPresenter.show(context, result);
      }
    }
  }

  Widget _buildBookItem(Book book) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: ListTile(
        leading: book.coverUrl.isNotEmpty
            ? CachedImage(
                imageUrl: book.coverUrl,
                width: 50,
                height: 70,
                fit: BoxFit.cover,
                borderRadius: 4,
              )
            : const Icon(Icons.book, size: 40),
        title: Text(
          book.title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('by ${book.author}', overflow: TextOverflow.ellipsis),
            Text(book.genre),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text('${book.rating}'),
                const SizedBox(width: 16),
                const Icon(Icons.attach_money, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Text(Formatters.formatCurrency(book.price)),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditBookDialog(book),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteBook(book),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Books'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _bookProvider.loadBooks(),
          ),
        ],
      ),
      body: Consumer<BookProvider>(
        builder: (context, provider, child) {
          if (provider.isloading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    provider.error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.loadBooks,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.visibleBooks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.book, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No Books Available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Click + to add your first book',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.visibleBooks.length,
            itemBuilder: (context, index) {
              final book = provider.visibleBooks[index];
              return _buildBookItem(book);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBookDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
