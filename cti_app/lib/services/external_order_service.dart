// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cti_app/models/external_order.dart';
import 'package:cti_app/controller/external_orders_controller.dart';

class ExternalOrderService extends ChangeNotifier {
  final List<ExternalOrder> _externalOrders = [];

  List<ExternalOrder> get externalOrderList {
    final sorted = List<ExternalOrder>.from(_externalOrders);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(sorted);
  }

  Future<void> fetchExternalOrders() async {
    try {
      final orders = await ExternalOrdersController.fetchOrders();
      _externalOrders.clear();
      _externalOrders.addAll(orders);
      print('Commandes externes chargées avec succès !');
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des commandes externes: $e');
    }
  }

  Future<ExternalOrder> addExternalOrder(ExternalOrder order) async {
    try {
      final createdOrder = await ExternalOrdersController.addOrder(order);
      _externalOrders.insert(0, createdOrder);
      print('Commande externe ajoutée !');
      notifyListeners();
      return createdOrder;
    } catch (e) {
      print('Erreur: $e');
      throw Exception('Erreur lors de l\'ajout de la commande externe: $e');
    }
  }
}
