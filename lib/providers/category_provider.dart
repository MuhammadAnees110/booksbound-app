import 'package:booksbound_app/models/category_model.dart';
import 'package:booksbound_app/services/category_service.dart';
import 'package:flutter/material.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<CategoryModel> _categories = CategoryService.defaultCategories;
  bool _isLoading = false;
  String _error = '';

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String get error => _error;

  CategoryProvider() {
    loadCategories();
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _categoryService.seedDefaultCategories().catchError((_) {});

      _categoryService.getCategories().listen((cats) {
        _categories = cats;
        _isLoading = false;
        notifyListeners();
      }, onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
