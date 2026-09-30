import 'package:booksbound_app/constants/app_constants.dart';
import 'package:booksbound_app/models/book_model.dart';
import 'package:booksbound_app/utils/error_mapper.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class BooksService {
  static const int _defaultPageSize = 20;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Fetch books in fixed-size pages so the local catalog contains every book.
  Future<Result<List<Book>>> fetchBooks({
    DocumentSnapshot<Map<String, dynamic>>? lastDoc,
    int pageSize = _defaultPageSize,
  }) async {
    try {
      final books = <Book>[];
      var cursor = lastDoc;

      while (true) {
        Query<Map<String, dynamic>> query = _firestore
            .collection(AppConstants.booksCollection)
            .limit(pageSize);
        if (cursor != null) query = query.startAfterDocument(cursor);

        final snapshot = await query.get();
        books.addAll(snapshot.docs.map(Book.fromJson));
        if (snapshot.docs.length < pageSize) break;
        cursor = snapshot.docs.last;
      }

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
  Future<Result<String>> addBook(Book book, {XFile? imageFile}) async {
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
  Future<Result<void>> updateBook(
    String bookId,
    Book book, {
    XFile? imageFile,
  }) async {
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
          .limit(20)
          .get();

      final authorQuery = await _firestore
          .collection(AppConstants.booksCollection)
          .where('author', isGreaterThanOrEqualTo: query)
          .where('author', isLessThan: '${query}z')
          .limit(20)
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

      final books = querySnapshot.docs
          .map((doc) => Book.fromJson(doc))
          .toList();
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
  /// Uses [XFile.readAsBytes] + [putData] so it works on both mobile and web.
  Future<String> _uploadBookImage(XFile imageFile, String bookId) async {
    final fileName =
        'book_covers/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child(fileName);
    final bytes = await imageFile.readAsBytes();
    final snapshot = await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await snapshot.ref.getDownloadURL();
  }
}
