// ignore_for_file: avoid_print

import 'package:cti_app/controller/product_controller.dart';
import 'package:cti_app/models/product.dart';
import 'package:flutter/material.dart';

class ProductService extends ChangeNotifier {
  final List<Product> _products = [];

  List<Product> get productList {
    final sortedProducts = List<Product>.from(_products);
    sortedProducts.sort((a, b) => b.name.compareTo(a.name)); // Tri alphabétique Z-A
    return List.unmodifiable(sortedProducts);
  }

  /// Charger tous les produits depuis l'API
  Future<void> fetchProducts() async {
    try {
      final products = await ProductController.fetchProducts();
      _products.clear();
      _products.addAll(products);
      print('Produits chargés avec succès !');
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des produits: $e');
    }
  }

  /// Ajouter un nouveau produit
  void addProduct(Product product) async {
    try {
      final createdProduct = await ProductController.createProduct(product);
      _products.insert(0, createdProduct);
      print('Produit ajouté !');
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }
}
