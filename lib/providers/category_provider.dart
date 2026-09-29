import 'dart:async';

import 'package:booksbound_app/models/category_model.dart';
import 'package:booksbound_app/services/category_service.dart';
import 'package:flutter/material.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<CategoryModel> _categories = CategoryService.defaultCategories;
  bool _isLoading = false;
  String _error = '';
  StreamSubscription? _categoriesSubscription;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String get error => _error;

  CategoryProvider() {
    unawaited(loadCategories());
  }

  Future<void> loadCategories() async {
    unawaited(_categoriesSubscription?.cancel());
    _categoriesSubscription = null;
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      unawaited(_categoryService.seedDefaultCategories());

      _categoriesSubscription = _categoryService.getCategories().listen(
        (result) {
          if (result.isSuccess) {
            _categories = result.data ?? [];
            _error = '';
          } else {
            _error = result.message;
          }
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _error = e.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    unawaited(_categoriesSubscription?.cancel());
    _categoriesSubscription = null;
    super.dispose();
  }
}
