import 'dart:convert';
// ignore: implementation_imports
import 'package:cti_app/services/api_service.dart';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../constants/app_constant.dart';
import 'login_controller.dart';

class CategoryController {

  static const String _baseUrl = AppConstant.BASE_URL + AppConstant.CATEGORIE_URI; // Change l'URL selon ton API

  static Future<Map<String, String>> getHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Token ${await AuthController.getToken()}'
    };
  }

  // Récupérer toutes les catégories
  static Future<List<Category>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('${_baseUrl}list/'),
      headers: await ApiService.headers(),
    );
    final data = ApiService.processResponse(response) as List;
    return data.map((json) => Category.fromJson(json)).toList();
  }

  // Récupérer une catégorie par son ID
  static Future<Category> fetchCategorieById(int? id) async {
    final response = await http.get(
      Uri.parse('${_baseUrl}detail/$id/'),
      headers: await ApiService.headers(),
    );
    final data = ApiService.processResponse(response);
    return Category.fromJson(data);
  }

  static Future<String> fetchCategorieNameById(int? id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$id/'),
        headers: await getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['name']; // ou Categorie.fromJson(data).name
      } else if (response.statusCode == 404) {
        throw Exception('Catégorie non trouvée');
      } else {
        throw Exception('Échec du chargement de la catégorie: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  // Ajouter une nouvelle catégorie
  static Future<Category> addCategorie(Category categorie) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}create/'),
        headers: await getHeaders(),
        body: jsonEncode(categorie.toJson()),
      );

      if (response.statusCode == 201) {
        return Category.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Échec de l\'ajout: ${errorData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  // Modifier une catégorie existante
  /// Mettre à jour une catégorie (PUT)
  static Future<Category> updateCategory(Category category) async {
    if (category.id == null) throw Exception('Category ID is required for update');
    
    final response = await http.put(
      Uri.parse('${_baseUrl}update/${category.id}/'),
      headers: await ApiService.headers(),
      body: json.encode(category.toJson()),
    );
    final data = ApiService.processResponse(response);
    return Category.fromJson(data);
  }

  /// Supprimer une catégorie (DELETE)
  static Future<void> deleteCategory(int? id) async {
    final response = await http.delete(
      Uri.parse('${_baseUrl}delete/$id/'),
      headers: await ApiService.headers(),
    );
    
    if (response.statusCode != 204) {
      throw Exception('Échec de la suppression du client');
    }
  }

  // Méthode optionnelle: Recherche de catégories
  static Future<List<Category>> searchCategories(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}search/?q=$query'),
        headers: await getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Échec de la recherche: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }
}