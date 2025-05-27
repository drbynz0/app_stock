import 'dart:convert';

import 'package:cti_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/models/discounts.dart';
import '/constants/app_constant.dart';

class DiscountController with ChangeNotifier {
  static List<Discount> _discounts = [];

    static const String _baseUrl = AppConstant.BASE_URL + AppConstant.DISCOUNT_URI; // Change l'URL selon ton API

  static List<Discount> get discountList => _discounts;

  Discount? getById(int? id) {
    return _discounts.firstWhere((d) => d.id == id, orElse: () => Discount.empty());
  }

  static Future<Discount> getByProductId(int? productId) async {
    _discounts = await getDiscounts();
    return _discounts.firstWhere((d) => d.productId == productId, orElse: () => Discount.empty());
  }

  List<Discount> getByValidity(String validity) {
    return _discounts.where((d) => d.validity == validity).toList();
  }

  static Future<List<Discount>> getDiscounts() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: await ApiService.headers(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Discount.fromJson(json)).toList();
      } else {
        throw Exception('Échec du chargement des clients: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Ajouter un nouveau discounts
  static Future<Discount> createDiscount(Discount discount) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: await ApiService.headers(),
        body: json.encode(discount.toJson()),

      );

      if (response.statusCode == 201) {
        
        return Discount.fromJson(json.decode(response.body));
      } else {
        throw Exception('Échec de la création du discount: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  /// Appliquer une promotion à un produit (change inPromo à true)
  Future<void> applyDiscountToProduct(bool inPromo, int productId, double pricePromo) async {
    final url = Uri.parse('$_baseUrl/$productId');

    try {
      final response = await http.patch(
        url,
        headers: await ApiService.headers(),
        body: jsonEncode({'on_promo': inPromo, 'promo_price': pricePromo}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('Produit mis à jour avec succès.');
        notifyListeners();
      } else {
        debugPrint('Erreur de mise à jour: ${response.statusCode}');
        debugPrint('Message: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erreur lors de la requête PATCH: $e');
    }
  }

  // Mettre à jour un discount
  static Future<Discount> updateDiscount(Discount discount) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl${discount.id}/'),
        headers: await ApiService.headers(),
        body: json.encode(discount.toJson()),
      );

      if (response.statusCode == 200) {
        return Discount.fromJson(json.decode(response.body));
      } else {
        throw Exception('Échec de la mise à jour du discount');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Supprimer un discount
  static Future<void> deleteDiscount(int id) async {
    try {
      final response = await http.delete(Uri.parse(
        '$_baseUrl$id/'),
        headers: await ApiService.headers(),
        );
      
      if (response.statusCode != 204) {
        throw Exception('Échec de la suppression du discount');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}
