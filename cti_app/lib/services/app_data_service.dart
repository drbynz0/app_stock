// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:cti_app/controller/category_controller.dart';
import 'package:cti_app/controller/customer_controller.dart';
import 'package:cti_app/controller/discount_controller.dart';
import 'package:cti_app/controller/external_orders_controller.dart';
import 'package:cti_app/controller/historical_controller.dart';
import 'package:cti_app/controller/internal_orders_controller.dart';
import 'package:cti_app/controller/product_controller.dart';
import 'package:cti_app/controller/supplier_controller.dart';
import 'package:cti_app/controller/user_controller.dart';
import 'package:cti_app/models/activity.dart';
import 'package:cti_app/models/category.dart';
import 'package:cti_app/models/discounts.dart';
import 'package:cti_app/services/category_service.dart';
import 'package:cti_app/services/client_service.dart';
import 'package:cti_app/services/discount_service.dart';
import 'package:cti_app/services/external_order_service.dart';
import 'package:cti_app/services/internal_order_service.dart';
import 'package:cti_app/services/profile_service.dart';
import 'package:cti_app/services/product_service.dart';
import 'package:flutter/material.dart';
import '../models/client.dart';
import '../models/external_order.dart';
import '../models/internal_order.dart';
import '../models/supplier.dart';
import '../models/product.dart';
import 'package:provider/provider.dart';

class AppData extends ChangeNotifier {
  List<Client> _clients = [];
  List<ExternalOrder> _externalOrders = [];
  List<InternalOrder> _internalOrders = [];
  List<Payments> _payments = [];
  List<Supplier> _suppliers = [];
  List<Product> _products = [];
  List<Category> _categories = [];
  Map<String, dynamic>? _myPrivileges = {};
  List<Activity> _activities = [];
  List<Discount> _discounts = [];
  Map<String, dynamic>? _userData = {};



  AppData() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _userData = await UserController.fetchUserProfile();
    _clients = await CustomerController.getCustomers();
    _products = await ProductController.fetchProducts();
    _categories = await CategoryController.fetchCategories();
    _externalOrders = await ExternalOrdersController.fetchOrders();
    _internalOrders = await InternalOrdersController.fetchOrders();
    _suppliers = await SupplierController.getSuppliers();
    _myPrivileges = await UserController.fetchUserPrivileges();
    _activities = await HistoricalController.getAllHistorical();
    _discounts = await DiscountController.getDiscounts();
    notifyListeners();
  }

  Future<void> refreshDataService(BuildContext context) async {
    await context.read<ClientService>().fetchClients();
    await context.read<ProductService>().fetchProducts();
    await context.read<ExternalOrderService>().fetchExternalOrders();
    await context.read<InternalOrderService>().fetchInternalOrders();
    await context.read<DiscountService>().fetchDiscounts();
    await context.read<CategoryService>().fetchCategories();
    await context.read<ProfileService>().fetchAvailablePrivileges();
    await context.read<DiscountService>().fetchDiscounts();
    await context.read<ProfileService>().fetchUserProfile();
    notifyListeners();
  }

  // Getters
  List<Client> get clients => _clients;
  List<Product> get products => _products;
  List<Category> get categories => _categories;
  List<ExternalOrder> get externalOrders => _externalOrders;
  List<InternalOrder> get internalOrders => _internalOrders;
  List<Payments> get payments => _payments;
  List<Supplier> get suppliers => _suppliers;
  Map<String, dynamic>? get myPrivileges => _myPrivileges;
  List<Activity> get activities {
    final sortedActivities = List<Activity>.from(_activities);
    sortedActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return List.unmodifiable(sortedActivities);
  }
  List<Discount> get discounts => _discounts;
  Map<String, dynamic>? get userData => _userData;
  Supplier getSupplierById(int id) {
    return _suppliers.firstWhere((supplier) => supplier.id == id, orElse: () => Supplier.empty());
  }

  // Méthodes pour les clients
  Future<void> fetchClients() async {
    _clients = await CustomerController.getCustomers();
    notifyListeners();
  }

  Future<Client> addClient(Client client) async {
    try {
      final createdClient = await CustomerController.createCustomer(client);
      _clients.insert(0, createdClient);
      print('Client ajouté !');
      notifyListeners();
      return createdClient;
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  Future<Client> updateClient(Client client) async {
    try {
      final updatedClient = await CustomerController.updateCustomer(client);
      int index = _clients.indexWhere((c) => c.id == client.id);
      if (index != -1) {
        _clients[index] = updatedClient;
        print('Client mis à jour !');
      }
      notifyListeners();
      return updatedClient;
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  Future<void> deleteClient(int id) async {
    try {
      await CustomerController.deleteCustomer(id);
      _clients.removeWhere((client) => client.id == id);
      print('Client supprimé !');
      notifyListeners();
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  Client getClientById(int id) {
    return _clients.firstWhere((client) => client.id == id, orElse: () => Client.empty());
  }

  // Méthodes pour les produits
  Future<void> fetchProducts() async {
    _products = await ProductController.fetchProducts();
    notifyListeners();
  }

  Future<Product> addProduct(Product product, List<File> images) async {
    try {
      final createdProduct = await ProductController.createProductWithImages(product, images);
      _products.insert(0, createdProduct);
      print('Produit ajouté !');
      notifyListeners();
      return createdProduct;
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  Future<Product> updateProduct(Product product, List<File> images) async {
    try {
      final updatedProduct = await ProductController.updateProduct(product, images);
      int index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
        print('Produit mis à jour !');
      }
      notifyListeners();
      return updatedProduct;
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await ProductController.deleteProduct(id);
      _products.removeWhere((product) => product.id == id);
      print('Produit supprimé !');
      notifyListeners();
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  // Méthodes pour les commandes externes
  Future<void> fetchExternalOrders() async {
    _externalOrders = await ExternalOrdersController.fetchOrders();
    notifyListeners();
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
      rethrow;
    }
  }

  Future<ExternalOrder> updateExternalOrder(int orderId, ExternalOrder order) async {
    try {
      final updatedOrder = await ExternalOrdersController.updateOrder(orderId, order);
      int index = _externalOrders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _externalOrders[index] = updatedOrder;
        print('Commande externe mise à jour !');
      }
      notifyListeners();
      return updatedOrder;
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  Future<bool> deleteExternalOrder(int id) async {
    try {
      await ExternalOrdersController.deleteOrder(id);
      _externalOrders.removeWhere((order) => order.id == id);
      print('Commande externe supprimée !');
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  // Méthodes pour les commandes internes
  Future<void> fetchInternalOrders() async {
    _internalOrders = await InternalOrdersController.fetchOrders();
    notifyListeners();
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
      rethrow;
    }
  }

  Future<InternalOrder> updateInternalOrder(int orderId, InternalOrder order) async {
    try {
      final updatedOrder = await InternalOrdersController.updateOrder(orderId, order);
      int index = _internalOrders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _internalOrders[index] = updatedOrder;
        print('Commande interne mise à jour !');
      }
      notifyListeners();
      return updatedOrder;
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  Future<bool> deleteInternalOrder(int id) async {
    try {
      await InternalOrdersController.deleteOrder(id);
      _internalOrders.removeWhere((order) => order.id == id);
      print('Commande interne supprimée !');
      notifyListeners();
      return true;
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  InternalOrder getInternalOrderById(int id) {
    return _internalOrders.firstWhere((order) => order.id == id, orElse: () => InternalOrder.empty());
  }

  InternalOrder getInternalOrderByOrderNum(String orderNum) {
    return _internalOrders.firstWhere((order) => order.orderNum == orderNum, orElse: () => InternalOrder.empty());
  }

  InternalOrder getInternalOrderByClientId(int clientId) {
    return _internalOrders.firstWhere((order) => order.clientId == clientId, orElse: () => InternalOrder.empty());
  }

  // Méthodes pour les paiements
  Future<void> fetchPayments(int orderId) async {
    _payments = await InternalOrdersController.fetchPaymentsOrder(orderId);
    notifyListeners();
  }

  Future<Payments> addPayment(int orderId, Payments payment) async {
    try {
      final createdPayment = await InternalOrdersController.addPayment(orderId, payment);
      _payments.insert(0, createdPayment);
      print('Paiement ajouté !');
      notifyListeners();
      return createdPayment;
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  void updatePayment(int orderId, Payments payment) async {
    try {
      //   static Future<bool> updatePayment(int orderId, int paymentId, Payments payment) async {
      await InternalOrdersController.updatePayment(orderId, payment);
      int index = _payments.indexWhere((p) => p.id == payment.id);
      if (index != -1) {
        _payments[index] = payment;
        print('Paiement mis à jour !');
      }
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }

  // Méthodes pour les fournisseurs
  Future<void> fetchSuppliers() async {
    _suppliers = await SupplierController.getSuppliers();
    notifyListeners();
  }

  Future<Supplier> addSupplier(Supplier supplier) async {
    try {
      final createdSupplier = await SupplierController.addSupplier(supplier);
      _suppliers.insert(0, createdSupplier);
      print('Fournisseur ajouté !');
      notifyListeners();
      return createdSupplier;
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  Future<Supplier> updateSupplier(Supplier supplier) async {
    try {
      final updatedSupplier = await SupplierController.updateSupplier(supplier.id, supplier);
      int index = _suppliers.indexWhere((s) => s.id == supplier.id);
      if (index != -1) {
        _suppliers[index] = updatedSupplier;
        print('Fournisseur mis à jour !');
      }
      notifyListeners();
      return updatedSupplier;
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  Future<void> deleteSupplier(int id) async {
    try {
      await SupplierController.deleteSupplier(id);
      _suppliers.removeWhere((supplier) => supplier.id == id);
      print('Fournisseur supprimé !');
      notifyListeners();
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  // Méthodes pour les catégories
  Future<void> fetchCategories() async {
    _categories = await CategoryController.fetchCategories();
    notifyListeners();
  }

  Category getCategoryById(int id) {
    return _categories.firstWhere((category) => category.id == id, orElse: () => Category.empty());
  }

  Future<Category> addCategory(Category category) async {
    try {
      final createdCategory = await CategoryController.addCategorie(category);
      _categories.insert(0, createdCategory);
      print('Catégorie ajoutée !');
      notifyListeners();
      return createdCategory;
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  Future<Category> updateCategory(Category category) async {
    try {
      final updatedCategory = await CategoryController.updateCategory(category);
      int index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = updatedCategory;
        print('Catégorie mise à jour !');
      }
      notifyListeners();
      return updatedCategory;
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await CategoryController.deleteCategory(id);
      _categories.removeWhere((category) => category.id == id);
      print('Catégorie supprimée !');
      notifyListeners();
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  // Méthodes pour les activités
  Future<void> fetchActivities() async {
    _activities = await HistoricalController.getAllHistorical();
    notifyListeners();
  }

  Future<Activity> addActivity(Activity activity) async {
    try {
      final createdActivity = await HistoricalController.addActivity(activity);
      _activities.insert(0, createdActivity);
      print('Activité ajoutée !');
      notifyListeners();
      return createdActivity;
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  Future<Activity> updateActivity(Activity activity) async {
    try {
      final updatedActivity = await HistoricalController.updateActivity(activity.id!, activity);
      int index = _activities.indexWhere((a) => a.id == activity.id);
      if (index != -1) {
        _activities[index] = updatedActivity;
        print('Activité mise à jour !');
      }
      notifyListeners();
      return updatedActivity;
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  Future<void> deleteActivity(int id) async {
    try {
      await HistoricalController.deleteActivity(id);
      _activities.removeWhere((activity) => activity.id == id);
      print('Activité supprimée !');
      notifyListeners();
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  Future<void> deleteAllActivities() async {
    try {
      await HistoricalController.deleteAllActivities();
      _activities.clear();
      print('Toutes les activités supprimées !');
      notifyListeners();
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  // Méthodes pour les réductions
  Future<void> fetchDiscounts() async {
    _discounts = await DiscountController.getDiscounts();
    notifyListeners();
  }

  Future<Discount> addDiscount(Discount discount) async {
    try {
      final createdDiscount = await DiscountController.createDiscount(discount);
      _discounts.insert(0, createdDiscount);
      print('Réduction ajoutée !');
      notifyListeners();
      return createdDiscount;
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  Future<Discount> updateDiscount(Discount discount) async {
    try {
      final updatedDiscount = await DiscountController.updateDiscount(discount);
      int index = _discounts.indexWhere((d) => d.id == discount.id);
      if (index != -1) {
        _discounts[index] = updatedDiscount;
        print('Réduction mise à jour !');
      }
      notifyListeners();
      return updatedDiscount;
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  Future<void> deleteDiscount(int id) async {
    try {
      await DiscountController.deleteDiscount(id);
      _discounts.removeWhere((discount) => discount.id == id);
      print('Réduction supprimée !');
      notifyListeners();
    } catch (e) {
      print('Erreur: $e');
      rethrow;
    }
  }

  // Méthodes pour les données utilisateur
  Future<void> fetchUserData() async {
    _userData = await UserController.fetchUserProfile();
    print('Données utilisateur récupérées: $_userData');
    notifyListeners();
  }

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final profile = await UserController.fetchUserProfile();
      _userData = profile;
      notifyListeners();
      return _userData;
    } catch (e) {
      print('Erreur lors de la récupération du profil utilisateur : $e');
      rethrow;
    }
  }

  // Autres méthodes
  void clearData() {
    _clients.clear();
    _products.clear();
    _categories.clear();
    _externalOrders.clear();
    _internalOrders.clear();
    _suppliers.clear();
    _myPrivileges = {};
    _activities.clear();
    notifyListeners();
  }

  Future<void> refreshData() async {
    await _loadInitialData();
    notifyListeners();
  }

  bool hasPrivilege(String privilege) {
    return _myPrivileges?[privilege] ?? false;
  }

  Map<String, dynamic>? getAvailablePrivileges() {
    return _myPrivileges;
  }

  Map<String, dynamic>? getUserProfile() {
    return _myPrivileges;
  }

  Map<String, dynamic>? getUserProfileData() {
    return _userData;
  }
}