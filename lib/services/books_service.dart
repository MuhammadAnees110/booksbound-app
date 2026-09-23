import 'dart:convert';
import 'dart:io';

import 'package:booksbound_app/constants/app_constants.dart';
import 'package:booksbound_app/models/book_model.dart';
import 'package:booksbound_app/utils/error_mapper.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BooksService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Fetch all books
  Future<Result<List<Book>>> fetchBooks() async {
    try {
      final snapshot =
          await _firestore.collection(AppConstants.booksCollection).get();

      final books = snapshot.docs.map((doc) {
        return Book.fromJson(doc);
      }).toList();
      return Result.success(books);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  // Get single book by ID
  Future<Result<Book>> getBookById(String bookId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.booksCollection)
          .doc(bookId)
          .get();
      if (doc.exists) {
        return Result.success(Book.fromJson(doc));
      }
      return Result.error(ResultStatus.notFound, 'Book not found');
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  // Add new book
  Future<Result<String>> addBook(Book book, {File? imageFile}) async {
    try {
      final bookData = book.toMap();

      if (imageFile != null) {
        final downloadUrl = await _uploadBookImage(imageFile, book.id);
        bookData['coverUrl'] = downloadUrl;
      }

      final docRef = await _firestore
          .collection(AppConstants.booksCollection)
          .add(bookData);
      return Result.created(docRef.id);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  // Update existing book
  Future<Result<void>> updateBook(String bookId, Book book, {File? imageFile}) async {
    try {
      final updateData = book.toMap();

      if (imageFile != null) {
        final downloadUrl = await _uploadBookImage(imageFile, bookId);
        updateData['coverUrl'] = downloadUrl;
      }

      await _firestore
          .collection(AppConstants.booksCollection)
          .doc(bookId)
          .update(updateData);
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  // Delete book
  Future<Result<void>> deleteBook(String bookId) async {
    try {
      await _firestore
          .collection(AppConstants.booksCollection)
          .doc(bookId)
          .delete();
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  // Search books
  Future<Result<List<Book>>> searchBooks(String query) async {
    try {
      final titleQuery = await _firestore
          .collection(AppConstants.booksCollection)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: '${query}z')
          .get();

      final authorQuery = await _firestore
          .collection(AppConstants.booksCollection)
          .where('author', isGreaterThanOrEqualTo: query)
          .where('author', isLessThan: '${query}z')
          .get();

      final allBooks = [
        ...titleQuery.docs.map((doc) => Book.fromJson(doc)),
        ...authorQuery.docs.map((doc) => Book.fromJson(doc)),
      ];

      final uniqueBooks = <String, Book>{};
      for (var book in allBooks) {
        uniqueBooks[book.id] = book;
      }

      return Result.success(uniqueBooks.values.toList());
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  // Get books by genre / category
  Future<Result<List<Book>>> getBooksByGenre(String genre) async {
    try {
      final trimmed = genre.trim();
      final normalized = trimmed.toLowerCase();
      final querySnapshot = await _firestore
          .collection(AppConstants.booksCollection)
          .where(
            Filter.or(
              Filter('genre', isEqualTo: trimmed),
              Filter('genre', isEqualTo: normalized),
              Filter('category', isEqualTo: trimmed),
              Filter('category', isEqualTo: normalized),
              Filter('category_lowercase', isEqualTo: normalized),
            ),
          )
          .get();

      final Map<String, Book> uniqueBooks = {};
      for (final doc in querySnapshot.docs) {
        final book = Book.fromJson(doc);
        uniqueBooks[book.id] = book;
      }
      return Result.success(uniqueBooks.values.toList());
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  // Get bestsellers
  Future<Result<List<Book>>> getBestsellers() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.booksCollection)
          .where('isBestseller', isEqualTo: true)
          .limit(10)
          .get();

      final books =
          querySnapshot.docs.map((doc) => Book.fromJson(doc)).toList();
      return Result.success(books);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  /// Uploads [imageFile] to Firebase Storage and returns the public download URL.
  /// If Firebase Storage is unavailable (e.g. Spark free tier), falls back to Base64.
  Future<String> _uploadBookImage(File imageFile, String bookId) async {
    try {
      final fileName =
          'book_covers/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);
      final snapshot = await ref.putFile(imageFile);
      return await snapshot.ref.getDownloadURL();
    } catch (_) {
      // Graceful fallback to Base64 when Storage is disabled on free tier
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    }
  }
}