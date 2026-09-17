import 'package:booksbound_app/constants/app_constants.dart';
import 'package:booksbound_app/models/category_model.dart';
import 'package:booksbound_app/utils/error_mapper.dart';
import 'package:booksbound_app/utils/result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const List<CategoryModel> defaultCategories = [
    CategoryModel(
      id: 'fiction',
      name: 'Fiction',
      imageUrl:
          'https://images.unsplash.com/photo-1476275466078-4007374efbbe?w=400',
      description: 'Novels, drama, and imaginative literature',
    ),
    CategoryModel(
      id: 'non-fiction',
      name: 'Non-Fiction',
      imageUrl:
          'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=400',
      description: 'Real-world facts, essays, and analysis',
    ),
    CategoryModel(
      id: 'children',
      name: 'Children',
      imageUrl:
          'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400',
      description: 'Picture books, fairy tales, and early readers',
    ),
    CategoryModel(
      id: 'academic',
      name: 'Academic',
      imageUrl:
          'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?w=400',
      description: 'Textbooks, research, and educational resources',
    ),
    CategoryModel(
      id: 'science',
      name: 'Science',
      imageUrl:
          'https://images.unsplash.com/photo-1507668077129-56e32842fceb?w=400',
      description: 'Physics, chemistry, biology, and the cosmos',
    ),
    CategoryModel(
      id: 'history',
      name: 'History',
      imageUrl:
          'https://images.unsplash.com/photo-1461360370896-922624d12aa1?w=400',
      description: 'Historical events, civilizations, and narratives',
    ),
    CategoryModel(
      id: 'biography',
      name: 'Biography',
      imageUrl:
          'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400',
      description: 'Memoirs and lives of extraordinary figures',
    ),
    CategoryModel(
      id: 'religion',
      name: 'Religion',
      imageUrl:
          'https://images.unsplash.com/photo-1519817650390-64a93db51149?w=400',
      description: 'Spiritual guides, theology, and philosophy',
    ),
  ];

  Stream<Result<List<CategoryModel>>> getCategories() {
    return _firestore
        .collection(AppConstants.categoriesCollection)
        .snapshots()
        .map((snapshot) {
      try {
        if (snapshot.docs.isEmpty) {
          return Result.success(defaultCategories);
        }
        final cats = snapshot.docs.map((doc) {
          return CategoryModel.fromMap(doc.data(), id: doc.id);
        }).toList();
        return Result.success(cats);
      } catch (e) {
        return Result<List<CategoryModel>>.error(
            ResultStatus.serverError, 'Failed to parse categories');
      }
    }).handleError((e) {
      if (e is FirebaseException) {
        return ErrorMapper.fromFirestore<List<CategoryModel>>(e);
      }
      return ErrorMapper.fromGeneric<List<CategoryModel>>(e);
    });
  }

  Future<Result<CategoryModel?>> getCategoryById(String id) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(id)
          .get();
      if (doc.exists && doc.data() != null) {
        return Result.success(CategoryModel.fromMap(doc.data()!, id: doc.id));
      }
      try {
        return Result.success(
            defaultCategories.firstWhere((cat) => cat.id == id));
      } catch (_) {
        return Result.error(ResultStatus.notFound, 'Category not found');
      }
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }

  Future<Result<void>> seedDefaultCategories() async {
    try {
      final snap = await _firestore
          .collection(AppConstants.categoriesCollection)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        final batch = _firestore.batch();
        for (final cat in defaultCategories) {
          final docRef = _firestore
              .collection(AppConstants.categoriesCollection)
              .doc(cat.id);
          batch.set(docRef, cat.toJson());
        }
        await batch.commit();
      }
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return ErrorMapper.fromAuth(e);
    } on FirebaseException catch (e) {
      return ErrorMapper.fromFirebase(e);
    } catch (e) {
      return ErrorMapper.fromGeneric(e);
    }
  }
}
