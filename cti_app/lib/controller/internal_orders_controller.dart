import 'dart:convert';
import 'package:cti_app/constants/app_constant.dart';
import 'package:cti_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/internal_order.dart'; // Adapte le chemin selon ton projet

class InternalOrdersController {
  static const String baseUrl = AppConstant.BASE_URL + AppConstant.INTERNAL_ORDER_URI;

  // Récupérer toutes les commandes internes
  static Future<List<InternalOrder>> fetchOrders() async {
    final response = await http.get(Uri.parse(baseUrl),
      headers: await ApiService.headers(),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => InternalOrder.fromJson(e)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des commandes internes: ${response.statusCode}');
    }
  }

  // Récupérer une commande par ID
  static Future<InternalOrder> fetchOrderById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl$id/'));
    if (response.statusCode == 200) {
      return InternalOrder.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Commande interne non trouvée');
    }
  }

  // Ajouter une commande interne
  static Future<InternalOrder> addOrder(InternalOrder order) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await ApiService.headers(),
      body: jsonEncode(order.toJson()),
    );
    if (response.statusCode == 201) {
      return InternalOrder.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Erreur lors de la création de la commande interne: ${response.body}');
    }
  }

  // Modifier une commande interne
  static Future<InternalOrder> updateOrder(int id, InternalOrder order) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$id/'),
        headers: await ApiService.headers(),
        body: jsonEncode(order.toJson()),
      );
      if (response.statusCode == 200) {
        return InternalOrder.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('Erreur lors de la modification: ${response.statusCode} ${response.body}');
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

  // Récupérer les paiements d'une commande interne
  static Future<List<Payments>> fetchPaymentsOrder(int orderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl$orderId/payments/'),
      headers: await ApiService.headers(),
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final List<dynamic>? paymentsData = responseData;
      final List<Payments> payments = paymentsData!.map((e) => Payments.fromJson(e)).toList();
      return payments;
    } else {
      throw Exception('Erreur lors de la récupération des paiements : ${response.body}');
    }
  }

  // Ajout d'un paiement à une commande interne
  static Future<Payments> addPayment(int orderId, Payments payment) async {
    final response = await http.post(
      Uri.parse('$baseUrl$orderId/payments/'),
      headers: await ApiService.headers(),
      body: jsonEncode(payment.toJson()
      ),
    );
    if (response.statusCode == 201) {
    return Payments.fromJson(json.decode(response.body));    
    } else {
      throw Exception('Erreur lors de l\'ajout du paiement: ${response.body}');
    }
  }
  static Future<bool> deletePayment(int orderId, int paymentId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$orderId/payments/$paymentId/'),
      headers: await ApiService.headers(),
    );
    if (response.statusCode == 204) {
      return true;
    } else {
      throw Exception('Erreur lors de la suppression du paiement: ${response.body}');
    }
  }
  static Future<bool> updatePayment(int orderId, Payments payment) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$orderId/payments/${payment.id}/'),
      headers: await ApiService.headers(),
      body: jsonEncode(payment.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Erreur lors de la mise à jour du paiement: ${response.body}');
    }
  } 
}