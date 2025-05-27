import 'dart:convert';
import 'package:cti_app/constants/app_constant.dart';
import 'package:cti_app/models/factures.dart';
import 'package:cti_app/services/api_service.dart';
import 'package:http/http.dart' as http;

class FactureClientController {
  static const String baseUrl = AppConstant.BASE_URL + AppConstant.FACTURE_CLIENT_URI;

  // 🔹 Récupérer toutes les factures
  static Future<List<FactureClient>> getFactures() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: await ApiService.headers(),
    );
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((item) => FactureClient.fromJson(item)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des factures');
    }
  }

  // 🔹 Récupérer une facture par ID
  static Future<FactureClient> getFactureById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id/'),
      headers: await ApiService.headers(),
    );
    if (response.statusCode == 200) {
      return FactureClient.fromJson(json.decode(response.body));
    } else {
      throw Exception('Facture non trouvée');
    }
  }

  // 🔹 Ajouter une facture
  static Future<FactureClient> addFacture(FactureClient facture) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await ApiService.headers(),
      body: json.encode(facture.toJson()),
    );
    if (response.statusCode == 201) {
      return FactureClient.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur lors de l\'ajout de la facture: ${response.body}');
    }
  }

  // 🔹 Supprimer une facture
  static Future<void> deleteFacture(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id/'),
      headers: await ApiService.headers(),
      );
    if (response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression de la facture');
    }
  }

  // 🔹 Mettre à jour une facture (optionnel)
  static Future<FactureClient> updateFacture(FactureClient facture) async {
    if (facture.id == null) throw Exception("ID manquant pour la mise à jour");
    final response = await http.put(
      Uri.parse('$baseUrl/${facture.id}/'),
      headers: await ApiService.headers(),
      body: json.encode(facture.toJson()),
    );
    if (response.statusCode == 200) {
      return FactureClient.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur lors de la mise à jour de la facture');
    }
  }
}

class FactureSupplierController {
  static const String baseUrl = AppConstant.BASE_URL + AppConstant.FACTURE_FOURNISSEUR_URI;

  // 🔹 Récupérer toutes les factures
  static Future<List<FactureFournisseur>> getFactures() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: await ApiService.headers(),
    );
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((item) => FactureFournisseur.fromJson(item)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des factures');
    }
  }

  // 🔹 Récupérer une facture par ID
  static Future<FactureFournisseur> getFactureById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id/'),
      headers: await ApiService.headers(),
    );
    if (response.statusCode == 200) {
      return FactureFournisseur.fromJson(json.decode(response.body));
    } else {
      throw Exception('Facture non trouvée');
    }
  }

  // 🔹 Ajouter une facture
  static Future<FactureFournisseur> addFacture(FactureFournisseur facture) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await ApiService.headers(),
      body: json.encode(facture.toJson()),
    );
    if (response.statusCode == 201) {
      return FactureFournisseur.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur lors de l\'ajout de la facture: ${response.body}');
    }
  }

  // 🔹 Supprimer une facture
  static Future<void> deleteFacture(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id/'),
      headers: await ApiService.headers(),
      );
    if (response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression de la facture');
    }
  }

  // 🔹 Mettre à jour une facture (optionnel)
  static Future<FactureFournisseur> updateFacture(FactureFournisseur facture) async {
    if (facture.id == null) throw Exception("ID manquant pour la mise à jour");
    final response = await http.put(
      Uri.parse('$baseUrl${facture.id}/'),
      headers: await ApiService.headers(),
      body: json.encode(facture.toJson()),
    );
    if (response.statusCode == 200) {
      return FactureFournisseur.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur lors de la mise à jour de la facture: ${response.body}');
    }
  }
}