// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cti_app/models/category.dart';
import 'package:cti_app/controller/category_controller.dart';

class CategoryService extends ChangeNotifier {
  final List<Category> _categories = [];

  List<Category> get categoryList {
    final sorted = List<Category>.from(_categories);
    sorted.sort((a, b) => a.name.compareTo(b.name)); // Tri alphabétique
    return List.unmodifiable(sorted);
  }

  Future<void> fetchCategories() async {
    try {
      final categories = await CategoryController.fetchCategories();
      _categories.clear();
      _categories.addAll(categories);
      print('Catégories chargées avec succès !');
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des catégories : $e');
    }
  }

  void addCategory(Category category) async {
    try {
      final createdCategory = await CategoryController.addCategorie(category);
      _categories.insert(0, createdCategory);
      print('Catégorie ajoutée !');
      notifyListeners();
    } catch (e) {
      print('Erreur : $e');
    }
  }
}
