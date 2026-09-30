import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:booksbound_app/models/review_model.dart';

class Book {
  String id;
  final String title;
  final String author;
  final String genre;
  final String description;
  final String coverUrl;
  final double price;
  final bool isBestseller;
  final DateTime releaseDate;
  final String isbn;
  final double rating;
  final List<ReviewModel> reviews;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.description,
    required this.coverUrl,
    required this.price,
    required this.isBestseller,
    required this.releaseDate,
    required this.isbn,
    required this.rating,
    this.reviews = const [],
  });

  factory Book.fromJson(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Book.fromMap(data, id: doc.id);
  }

  factory Book.fromMap(Map<String, dynamic> data, {String id = ''}) {
    DateTime parsedDate;
    if (data['releaseDate'] is Timestamp) {
      parsedDate = (data['releaseDate'] as Timestamp).toDate();
    } else if (data['releaseDate'] is String) {
      parsedDate = DateTime.tryParse(data['releaseDate']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return Book(
      id: id.isNotEmpty ? id : (data['id'] ?? ''),
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      genre: data['genre'] ?? data['category'] ?? '',
      description: data['description'] ?? '',
      coverUrl: (data['coverUrl'] as String?) ?? '',
      isbn: data['isbn'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      isBestseller: data['isBestseller'] ?? false,
      releaseDate: parsedDate,
      reviews: (data['reviews'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => ReviewModel.fromMap(e))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'genre': genre,
      'category': genre,
      'category_lowercase': genre.toLowerCase().trim(),
      'description': description,
      'coverUrl': coverUrl,
      'price': price,
      'isBestseller': isBestseller,
      'releaseDate': Timestamp.fromDate(releaseDate),
      'isbn': isbn,
      'rating': rating,
      'reviews': reviews.map((r) => r.toMap()).toList(), // ✅ FIX
    };
  }
}
