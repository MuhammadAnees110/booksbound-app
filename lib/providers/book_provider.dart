import 'package:booksbound_app/models/book_model.dart';
import 'package:booksbound_app/services/books_service.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum SortType { priceLow, priceHigh, newest, popularity }

class BookProvider extends ChangeNotifier {
  final BooksService _service = BooksService();
  bool _isloading = false;
  String _error = "";
  List<Book> _books = [];
  List<Book> _filteredBooks = [];
  String _searchQuery = "";
  List<Book> get visibleBooks => _filteredBooks;
  bool get isloading => _isloading;
  String get error => _error;
  List<Book> get bestsellers => _books.where((b) => b.isBestseller).toList();
  List<Book> get newArrivals => _books
      .where(
        (b) => b.releaseDate.isAfter(
          DateTime.now().subtract(const Duration(days: 365)),
        ),
      )
      .toList();

  Future<void> loadBooks() async {
    _isloading = true;
    _error = "";
    notifyListeners();

    final result = await _service.fetchBooks();
    if (result.isSuccess) {
      _books = result.data ?? [];
      _filteredBooks = List.from(_books);
      _error = "";
    } else {
      _error = result.message;
    }
    _isloading = false;
    notifyListeners();
  }

  List<Book> search(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return _books;

    return _books
        .where(
          (b) =>
              b.title.toLowerCase().contains(normalizedQuery) ||
              b.author.toLowerCase().contains(normalizedQuery) ||
              b.genre.toLowerCase().startsWith(normalizedQuery),
        )
        .toList();
  }

  void sortBy(SortType criteria) {
    switch (criteria) {
      case SortType.priceLow:
        _filteredBooks.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortType.priceHigh:
        _filteredBooks.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortType.popularity:
        _filteredBooks.sort(
          (a, b) =>
              (b.isBestseller ? 1 : 0).compareTo((a.isBestseller ? 1 : 0)),
        );
        break;
      case SortType.newest:
        _filteredBooks.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));
        break;
    }
    notifyListeners();
  }

  Future<Result<void>> deleteBook(String bookId) async {
    _isloading = true;
    _error = '';
    notifyListeners();

    final result = await _service.deleteBook(bookId);
    if (result.isSuccess) {
      _books.removeWhere((book) => book.id == bookId);
      _applySearch();
    } else {
      _error = result.message;
    }
    _isloading = false;
    notifyListeners();
    return result;
  }

  Future<Result<Book>> getBookById(String bookId) async {
    _isloading = true;
    _error = '';
    notifyListeners();

    final result = await _service.getBookById(bookId);
    if (result.isSuccess) {
      _error = '';
    } else {
      _error = result.message;
    }
    _isloading = false;
    notifyListeners();
    return result;
  }

  Future<Result<String>> addBook(Book book, {XFile? imageFile}) async {
    _isloading = true;
    _error = '';
    notifyListeners();

    final result = await _service.addBook(book, imageFile: imageFile);
    if (result.isSuccess) {
      book.id = result.data ?? book.id;
      _books.add(book);
      _applySearch();
    } else {
      _error = result.message;
    }
    _isloading = false;
    notifyListeners();
    return result;
  }

  Future<Result<void>> updateBook(
    String bookId,
    Book book, {
    XFile? imageFile,
  }) async {
    _isloading = true;
    _error = '';
    notifyListeners();

    final result = await _service.updateBook(
      bookId,
      book,
      imageFile: imageFile,
    );
    if (result.isSuccess) {
      final index = _books.indexWhere((b) => b.id == bookId);
      if (index != -1) {
        _books[index] = book;
        _applySearch();
      }
    } else {
      _error = result.message;
    }
    _isloading = false;
    notifyListeners();
    return result;
  }

  Future<void> searchBooks(String query) async {
    _searchQuery = query.toLowerCase().trim();

    if (_searchQuery.isEmpty) {
      _filteredBooks = _books;
    } else {
      _isloading = true;
      notifyListeners();

      final result = await _service.searchBooks(_searchQuery);
      if (result.isSuccess) {
        _filteredBooks = result.data ?? [];
        _error = '';
      } else {
        _error = result.message;
        _filteredBooks = [];
      }
      _isloading = false;
      notifyListeners();
    }
    notifyListeners();
  }

  Future<List<Book>> getBooksByGenre(String genre) async {
    final result = await _service.getBooksByGenre(genre);
    if (result.isSuccess) {
      return result.data ?? [];
    } else {
      _error = result.message;
      notifyListeners();
      return [];
    }
  }

  Future<List<Book>> getBestsellers() async {
    final result = await _service.getBestsellers();
    if (result.isSuccess) {
      return result.data ?? [];
    } else {
      _error = result.message;
      notifyListeners();
      return [];
    }
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _filteredBooks = _books;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Apply search filter locally
  void _applySearch() {
    if (_searchQuery.isNotEmpty) {
      _filteredBooks = _books.where((book) {
        return book.title.toLowerCase().contains(_searchQuery) ||
            book.author.toLowerCase().contains(_searchQuery) ||
            book.genre.toLowerCase().contains(_searchQuery);
      }).toList();
    } else {
      _filteredBooks = _books;
    }
  }

  void clear() {
    _books = [];
    _filteredBooks = [];
    _isloading = false;
    _error = "";
    notifyListeners();
  }
}
