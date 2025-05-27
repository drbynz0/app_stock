// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:cti_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/models/product.dart';
import '/constants/app_constant.dart';

class ProductController {

 
  static const String _baseUrl = AppConstant.BASE_URL + AppConstant.PRODUCT_URI; // Change l'URL selon ton API

  /// Récupérer tous les produits
  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('${_baseUrl}list/'),
      headers: await ApiService.headers(),
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      SnackBar(
        content: Text('Erreur lors de la récupération des produits'),
        duration: Duration(seconds: 2),
      );
      throw Exception('Erreur lors de la récupération des produits : ${response.body}');
    }
  }

  // Récupérer un produit par ID
  static Future<Product> getProductById(int id) async {
    final response = await http.get(
      Uri.parse('${_baseUrl}details/$id/'),
      headers: await ApiService.headers(),
    );
    final data = ApiService.processResponse(response);
    return Product.fromJson(data);
  }

  // Rechercher des produits
  static Future<List<Product>> searchProducts({String? name, String? category}) async {
    final params = <String, String>{};
    if (name != null) params['name'] = name;
    if (category != null) params['category'] = category;

    final response = await http.get(
      Uri.parse('${_baseUrl}search/').replace(queryParameters: params),
      headers: await ApiService.headers(),
    );
    final data = ApiService.processResponse(response) as List;
    return data.map((json) => Product.fromJson(json)).toList();
  }

  // Créer un nouveau produit
  static Future<Product> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}create/'),
      headers: await ApiService.headers(),
      body: json.encode(product.toJson()),
    );
    final data = ApiService.processResponse(response);
    return Product.fromJson(data);
  }

  static Future<Product> updateProductStock({
    required int? productId,
    required int newStock,
  }) async {
    final response = await http.patch(
      Uri.parse('${_baseUrl}update/$productId/'),
      headers: await ApiService.headers(),
      body: jsonEncode({
        'stock': newStock,
        'available': newStock > 0,
        'updated_at': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur ${response.statusCode}: ${response.body}');
    }
  }

  // Supprimer un produit
  static Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('${_baseUrl}delete/$id/'),
      headers: await ApiService.headers(),
    );
    ApiService.processResponse(response);
  }

  // Extrait seulement la partie après /media/
  static String extractRelativePath(String fullUrl) {
    Uri uri = Uri.parse(fullUrl);
    String path = uri.path;
    if (path.startsWith('/media/')) {
      return path.substring('/media/'.length);
    }
    return path;
  }
  // Mettre à jour un produit
  static Future<Product> updateProduct(Product product, List<File> images) async {
    if (product.id == null) throw Exception('Product ID is required for update');
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('${_baseUrl}update/${product.id}/'),
    );
    // Champs texte
    request.fields['name'] = product.name;
    request.fields['code'] = product.code;
    request.fields['marque'] = product.marque;
    request.fields['stock'] = product.stock.toString();
    request.fields['available'] = product.available.toString();
    request.fields['price'] = product.price.toString();
    request.fields['description'] = product.description ?? 'Aucune description';
    request.fields['on_promo'] = product.onPromo.toString();
    request.fields['category_id'] = product.category.id.toString();
    if (product.promoPrice != null) {
      request.fields['promo_price'] = product.promoPrice.toString();
    }
    List<String> relativePaths = product.images.map(extractRelativePath).toList();
    // Envoyez les URLs des images existantes sous forme de JSON
    if (product.images.isNotEmpty) {
      request.fields['images'] = jsonEncode(relativePaths);
    }
    // Images
    for (var image in images) {
      var file = await http.MultipartFile.fromPath('images', image.path);
      request.files.add(file);
    }
    request.headers.addAll(await ApiService.headers());
    
    // Envoi
    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Product.fromJson(json.decode(responseData));
    } else {
      throw Exception('Erreur serveur: $responseData');
    } 
  }

  //Envoie des images
  static Future<Product> createProductWithImages(Product product, List<File> images) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${_baseUrl}create/'),
    );

    // Champs texte
    request.fields['name'] = product.name;
    request.fields['code'] = product.code;
    request.fields['marque'] = product.marque;
    request.fields['stock'] = product.stock.toString();
    request.fields['available'] = product.available.toString();
    request.fields['price'] = product.price.toString();
    request.fields['description'] = product.description ?? 'Aucune description';
    request.fields['on_promo'] = product.onPromo.toString();
    request.fields['category_id'] = product.category.id.toString();
    if (product.promoPrice != null) {
      request.fields['promo_price'] = product.promoPrice.toString();
    }

    // Images
    for (var image in images) {
      var file = await http.MultipartFile.fromPath('images', image.path);
      request.files.add(file);
    }

    // Headers (Authorization, etc.)
    request.headers.addAll(await ApiService.headers());

    // Envoi
    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Product.fromJson(json.decode(responseData));
    } else {
      throw Exception('Erreur serveur: $responseData');
    }
  }

  /// Disponibilité du produit
  static updateAvailable(int? productId, bool? available) async {

    final response = await http.patch(
      Uri.parse('${_baseUrl}update/$productId/'),
      headers: await ApiService.headers(),

      body: jsonEncode({
        'available': available,
        'updated_at': DateTime.now().toIso8601String(),
        }),
    );
    if (response.statusCode != 200) {



      print('Erreur mise à jour disponibilité: ${response.body}');
      throw Exception('Erreur mise à jour disponibilité: ${response.statusCode}');
    }
  }

}





 

