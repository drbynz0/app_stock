// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cti_app/models/internal_order.dart';
import 'package:cti_app/controller/internal_orders_controller.dart';

class InternalOrderService extends ChangeNotifier {
  final List<InternalOrder> _internalOrders = [];
  final List<Payments> _payments = [];

  List<InternalOrder> get internalOrderList {
    final sorted = List<InternalOrder>.from(_internalOrders);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(sorted);
  }
  List<Payments> get paymentsList => List.unmodifiable(_payments);

  Future<void> fetchInternalOrders() async {
    try {
      final orders = await InternalOrdersController.fetchOrders();
      _internalOrders.clear();
      _internalOrders.addAll(orders);
      print('Commandes internes chargées avec succès !');
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des commandes internes: $e');
    }
  }
  Future<void> fetchPayments() async {
    try {
      final payments = await InternalOrdersController.fetchPaymentsOrder();
      _payments.clear();
      _payments.addAll(payments);
      print('Paiements chargés avec succès !');
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des paiements: $e');
    }
  }

  Future<InternalOrder> addInternalOrder(InternalOrder order) async {
    try {
      final createdOrder = await InternalOrdersController.addOrder(order);
      _internalOrders.insert(0, createdOrder);
      print('Commande interne ajoutée !');
      notifyListeners();
      return createdOrder;
    } catch (e) {
      print('Erreur: $e');
      throw Exception('Erreur lors de l\'ajout de la commande interne: $e');
    }
  }
}
