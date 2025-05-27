import 'dart:convert';
import 'package:cti_app/constants/app_constant.dart';
import 'package:cti_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/external_order.dart'; // Adapte le chemin selon ton projet

class ExternalOrdersController {
  static const String baseUrl = AppConstant.BASE_URL + AppConstant.EXTERNAL_ORDER_URI;

  // Récupérer toutes les commandes internes
  static Future<List<ExternalOrder>> fetchOrders() async {
    final response = await http.get(Uri.parse(baseUrl),
      headers: await ApiService.headers(),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => ExternalOrder.fromJson(e)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des commandes internes: ${response.statusCode}');
    }
  }

  // Récupérer une commande par ID
  static Future<ExternalOrder> fetchOrderById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl$id/'));
    if (response.statusCode == 200) {
      return ExternalOrder.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Commande interne non trouvée');
    }
  }

  // Ajouter une commande interne
  static Future<ExternalOrder> addOrder(ExternalOrder order) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await ApiService.headers(),
      body: jsonEncode(order.toJson()),
    );
    if (response.statusCode == 201) {
      return ExternalOrder.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Erreur lors de la création de la commande interne: ${response.body}');
    }
  }

  // Modifier une commande interne
  static Future<ExternalOrder> updateOrder(int id, ExternalOrder order) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$id/'),
        headers: await ApiService.headers(),
        body: jsonEncode(order.toJson()),
      );
      if (response.statusCode == 200) {
        return ExternalOrder.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('Erreur lors de la modification: ${response.statusCode}');
      }
    } catch (e, stack) {
    debugPrint('Erreur dans updateOrder: $e');
    debugPrint('Stack trace: $stack');
    rethrow;
  }
  }

    static Future<bool> updateOrderStatus({
    required int? orderId,
    required String newStatus,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$orderId/'),
      headers: await ApiService.headers(),
      body: jsonEncode({
        'status': newStatus,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Erreur ${response.statusCode}: ${response.body}');
    }
  }

  // Supprimer une commande interne
  static Future<bool> deleteOrder(int id) async {
      final response = await http.delete(
        Uri.parse('$baseUrl$id/'),
        headers: await ApiService.headers(),
        );
      if (response.statusCode != 204) {
        throw Exception('Erreur lors de la suppression ${response.body}');
      }
      return true;
  }
}