import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:booksbound_app/constants/app_constants.dart';
import 'package:booksbound_app/models/book_model.dart';

class BooksService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Fetch all books
  Future<List<Book>> fetchBooks() async {
    try {
      final snapshot = await _firestore.collection(AppConstants.booksCollection).get();

      return snapshot.docs.map((doc) {
        return Book.fromJson(doc);
      }).toList();
    } catch (e) {
      throw "Failed to fetch books: $e";
    }
  }

  // Get single book by ID
  Future<Book> getBookById(String bookId) async {
    try {
      final doc = await _firestore.collection(AppConstants.booksCollection).doc(bookId).get();
      if (doc.exists) {
        return Book.fromJson(doc);
      }
      throw Exception('Book not found');
    } catch (e) {
      debugPrint('Error getting book: $e');
      throw Exception('Failed to load book');
    }
  }

  // Add new book
  Future<String> addBook(Book book, {File? imageFile}) async {
    try {
      // Prepare book data
      final bookData = book.toMap();

      if (imageFile != null) {
        final downloadUrl = await _uploadBookImage(imageFile, book.id);
        bookData['coverUrl'] = downloadUrl;
      }

      // Add to Firestore
      final docRef = await _firestore.collection(AppConstants.booksCollection).add(bookData);
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding book: $e');
      throw Exception('Failed to add book');
    }
  }

  // Update existing book
  Future<void> updateBook(String bookId, Book book, {File? imageFile}) async {
    try {
      final updateData = book.toMap();

      if (imageFile != null) {
        final downloadUrl = await _uploadBookImage(imageFile, bookId);
        updateData['coverUrl'] = downloadUrl;
      }

      // Update in Firestore
      await _firestore.collection(AppConstants.booksCollection).doc(bookId).update(updateData);
    } catch (e) {
      debugPrint('Error updating book: $e');
      throw Exception('Failed to update book');
    }
  }

  // Delete book
  Future<void> deleteBook(String bookId) async {
    try {
      // Delete book from Firestore
      await _firestore.collection(AppConstants.booksCollection).doc(bookId).delete();
    } catch (e) {
      debugPrint('Error deleting book: $e');
      throw Exception('Failed to delete book');
    }
  }

  // Search books
  Future<List<Book>> searchBooks(String query) async {
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

      // Remove duplicates
      final uniqueBooks = <String, Book>{};
      for (var book in allBooks) {
        uniqueBooks[book.id] = book;
      }

      return uniqueBooks.values.toList();
    } catch (e) {
      debugPrint('Error searching books: $e');
      return [];
    }
  }

  // Get books by genre
  Future<List<Book>> getBooksByGenre(String genre) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.booksCollection)
          .where('genre', isEqualTo: genre)
          .get();

      return querySnapshot.docs.map((doc) => Book.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error getting books by genre: $e');
      return [];
    }
  }

  // Get bestsellers
  Future<List<Book>> getBestsellers() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.booksCollection)
          .where('isBestseller', isEqualTo: true)
          .limit(10)
          .get();

      return querySnapshot.docs.map((doc) => Book.fromJson(doc)).toList();
    } catch (e) {
      debugPrint('Error getting bestsellers: $e');
      return [];
    }
  }

  /// Uploads [imageFile] to Firebase Storage and returns the public download URL.
  Future<String> _uploadBookImage(File imageFile, String bookId) async {
    try {
      final fileName = 'book_covers/\${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);
      final snapshot = await ref.putFile(imageFile);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading book image: $e');
      throw Exception('Failed to upload image');
    }
  }
}