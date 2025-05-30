// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cti_app/models/discounts.dart';
import 'package:cti_app/controller/discount_controller.dart';

class DiscountService extends ChangeNotifier {
  final List<Discount> _discounts = [];

  List<Discount> get discountList {
    final sorted = List<Discount>.from(_discounts);
    sorted.sort((a, b) => b.dateDebut!.compareTo(a.dateDebut!)); // Tri alphabétique par nom
    return List.unmodifiable(sorted);
  }

  Future<void> fetchDiscounts() async {
    try {
      final discounts = await DiscountController.getDiscounts();
      _discounts.clear();
      _discounts.addAll(discounts);
      print('Remises chargées avec succès !');
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des remises : $e');
    }
  }

  void addDiscount(Discount discount) async {
    try {
      final createdDiscount = await DiscountController.createDiscount(discount);
      _discounts.insert(0, createdDiscount);
      print('Remise ajoutée !');
    } catch (e) {
      print('Erreur : $e');
    }
    notifyListeners();
  }
}
