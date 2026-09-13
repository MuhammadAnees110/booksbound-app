import 'dart:io';

import 'package:booksbound_app/models/book_model.dart';
import 'package:booksbound_app/services/books_service.dart';
import 'package:flutter/material.dart';

enum SortType { priceLow, priceHigh, newest, popularity }

class BookProvider extends ChangeNotifier {
  final BooksService _service = BooksService();
  bool _isloading = false;
  String _error = "";
  List<Book> _books = [];
  // List<Book> _visibleBooks = [];
  List<Book> _filteredBooks = [];
  String _searchQuery = "";
  List<Book> get visibleBooks => _filteredBooks;
  bool get isloading => _isloading;
  String get error => _error;
  List<Book> get bestsellers => _books.where((b) => b.isBestseller).toList();
  List<Book> get newArrivals => _books
      .where(
        (b) =>
            b.releaseDate.isAfter(DateTime.now().subtract(Duration(days: 365))),
      )
      .toList();

  Future<void> loadBooks() async {
    _isloading = true;
    _error = "";
    notifyListeners();
    try {
      _books = await _service.fetchBooks();
      _filteredBooks = List.from(_books);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  List<Book> search(String query) {
    return _books
        .where(
          (b) =>
              b.title.toLowerCase().contains(query.toLowerCase()) ||
              b.author.toLowerCase().contains(query.toLowerCase()) ||
              b.genre.toLowerCase().contains(query.toLowerCase()) ||
              b.isbn.contains(query),
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

  Future<bool> deleteBook(String bookId) async {
    _isloading = true;
    _error = '';
    notifyListeners();

    try {
      await _service.deleteBook(bookId);
      _books.removeWhere((book) => book.id == bookId);
      _applySearch();
      return true;
    } catch (e) {
      _error = 'Failed to delete book: $e';
      return false;
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  Future<Book?> getBookById(String bookId) async {
    try {
      return await _service.getBookById(bookId);
    } catch (e) {
      _error = 'Failed to load book: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> addBook(Book book, {File? imageFile}) async {
    _isloading = true;
    _error = '';
    notifyListeners();

    try {
      final bookId = await _service.addBook(book, imageFile: imageFile);
      book.id = bookId;
      _books.add(book);
      _applySearch();
      return true;
    } catch (e) {
      _error = 'Failed to add book: $e';
      return false;
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBook(String bookId, Book book, {File? imageFile}) async {
    _isloading = true;
    _error = '';
    notifyListeners();

    try {
      await _service.updateBook(bookId, book, imageFile: imageFile);

      final index = _books.indexWhere((b) => b.id == bookId);
      if (index != -1) {
        _books[index] = book;
        _applySearch();
      }
      return true;
    } catch (e) {
      _error = 'Failed to update book: $e';
      return false;
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  Future<void> searchBooks(String query) async {
    _searchQuery = query.toLowerCase().trim();

    if (_searchQuery.isEmpty) {
      _filteredBooks = _books;
    } else {
      _isloading = true;
      notifyListeners();

      try {
        _filteredBooks = await _service.searchBooks(_searchQuery);
      } catch (e) {
        _error = 'Search failed: $e';
        _filteredBooks = [];
      } finally {
        _isloading = false;
        notifyListeners();
      }
    }
    notifyListeners();
  }

  Future<List<Book>> getBooksByGenre(String genre) async {
    try {
      return await _service.getBooksByGenre(genre);
    } catch (e) {
      _error = 'Failed to get books by genre: $e';
      return [];
    }
  }

  Future<List<Book>> getBestsellers() async {
    try {
      return await _service.getBestsellers();
    } catch (e) {
      _error = 'Failed to get bestsellers: $e';
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
