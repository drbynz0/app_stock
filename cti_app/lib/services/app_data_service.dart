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
import 'package:provider/provider.dart'; // Assure-toi que c'est bien importé


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
    // Initialisation des données
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _clients = await CustomerController.getCustomers();
    _products = await ProductController.fetchProducts();
    _categories = await CategoryController.fetchCategories();
    _externalOrders = await ExternalOrdersController.fetchOrders();
    _internalOrders = await InternalOrdersController.fetchOrders();
    _payments = await InternalOrdersController.fetchPaymentsOrder();
    _payments = await InternalOrdersController.fetchPaymentsOrder();
    _suppliers = await  SupplierController.getSuppliers();
    _myPrivileges = await UserController.fetchUserPrivileges();
    _activities = await HistoricalController.getAllHistorical();
    _discounts = await DiscountController.getDiscounts();
    _userData = await UserController.fetchUserProfile();
    notifyListeners();

  }


Future<void> refreshDataService(BuildContext context) async {
  await context.read<ClientService>().fetchClients();
  await context.read<ProductService>().fetchProducts();
  await context.read<ExternalOrderService>().fetchExternalOrders();
  await context.read<InternalOrderService>().fetchPayments();
  await context.read<InternalOrderService>().fetchInternalOrders();
  await context.read<DiscountService>().fetchDiscounts();
  await context.read<CategoryService>().fetchCategories();
  await context.read<ProfileService>().fetchAvailablePrivileges();
  await context.read<DiscountService>().fetchDiscounts();
  await context.read<ProfileService>().fetchUserProfile();


  notifyListeners(); // Si tu veux notifier ce service (AppDataService), ok
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
  List<Activity> get activities => _activities;
  List<Discount> get discounts => _discounts;
  Map<String, dynamic>? get userData => _userData;

  Supplier getSupplierById(int id) {
    return _suppliers.firstWhere((supplier) => supplier.id == id, orElse: () => Supplier.empty());
  }

  // Méthodes pour récupérer, ajouter, supprimer ou mettre à jour des clients
  Future<void> fetchClients() async {
    _clients = await CustomerController.getCustomers();
    notifyListeners();
  }
  void addClient(Client client) async {
    try {
        await CustomerController.createCustomer(client);
        _clients.insert(0, client);
        print('Client ajoutée !');
      } catch (e) {
        print('Erreur: $e');
      }
    notifyListeners();
  }
  void updateClient(Client client) async {
    try {
      await CustomerController.updateCustomer(client);
      int index = _clients.indexWhere((c) => c.id == client.id);
      if (index != -1) {
        _clients[index] = client;
        print('Client mise à jour !');
      }
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }
  void deleteClient(int id) async {
    try {
      await CustomerController.deleteCustomer(id);
      _clients.removeWhere((client) => client.id == id);
      print('Client supprimée !');
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }

  // Méthodes pour récupérer, ajouter, supprimer ou mettre à jour des produits
  Future<void> fetchProducts() async {
    _products = await ProductController.fetchProducts();
    notifyListeners();
  }
  void addProduct(Product product) async {
    try {
      await ProductController.createProduct(product);
      _products.insert(0, product);
      print('Produit ajouté !');
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }
  void updateProduct(Product product, List<File> images) async {
    try {
      await ProductController.updateProduct(product, images);
      int index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        print('Produit mis à jour !');
      }
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }
  void deleteProduct(int id) async {
    try {
      await ProductController.deleteProduct(id);
      _products.removeWhere((product) => product.id == id);
      print('Produit supprimé !');
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }

  // Méthodes pour récupérer ajouter, supprimer ou mettre à jour des commandes externes
  Future<void> fetchExternalOrders() async {
    _externalOrders = await ExternalOrdersController.fetchOrders();
    notifyListeners();
  }
  void addExternalOrder(ExternalOrder order) async {
    try {
      await ExternalOrdersController.addOrder(order);
      _externalOrders.insert(0, order);
      print('Commande externe ajoutée !');
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }

  void updateExternalOrder(ExternalOrder order) async {
    try {
      await ExternalOrdersController.updateOrder(order.id!, order);
      int index = _externalOrders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        _externalOrders[index] = order;
        print('Commande externe mise à jour !');
      }
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }
  void deleteExternalOrder(int id) async {
    try {
      await ExternalOrdersController.deleteOrder(id);
      _externalOrders.removeWhere((order) => order.id == id);
      print('Commande externe supprimée !');
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }
  // Méthodes pour récupérer, ajouter, supprimer ou mettre à jour des commandes internes
  Future<void> fetchInternalOrders() async {
    _internalOrders = await InternalOrdersController.fetchOrders();
    notifyListeners();
  }
  Future<InternalOrder> addInternalOrder(InternalOrder order) async {
    try {
      final createdOrder = await InternalOrdersController.addOrder(order);
      _internalOrders.insert(0, order);
      print('Commande interne ajoutée !');
      notifyListeners();
      return createdOrder;
    } catch (e) {
      print('Erreur: $e');
      throw Exception('Erreur lors de l\'ajout de la commande interne: $e');
    }
  }
  void updateInternalOrder(InternalOrder order) async {
    try {
      await InternalOrdersController.updateOrder(order.id!, order);
      int index = _internalOrders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        _internalOrders[index] = order;
        print('Commande interne mise à jour !');
      }
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }
  void deleteInternalOrder(int id) async {
    try {
      await InternalOrdersController.deleteOrder(id);
      _internalOrders.removeWhere((order) => order.id == id);
      print('Commande interne supprimée !');
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }
  // Méthodes pour récupérer, ajouter, supprimer ou mettre à jour des paiements
  Future<void> fetchPayments() async {
    _payments = await InternalOrdersController.fetchPaymentsOrder();
    notifyListeners();
  }
  void addPayment(int orderId, Payments payment) async {
    try {
      await InternalOrdersController.addPayment(orderId, payment);
      _payments.insert(0, payment);
      print('Paiement ajouté !');
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
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
  // Méthodes pour récupérer ajouter, supprimer ou mettre à jour des fournisseurs
  Future<void> fetchSuppliers() async {
    _suppliers = await SupplierController.getSuppliers();
    notifyListeners();
  }
  void addSupplier(Supplier supplier) async {
    try {
      await SupplierController.addSupplier(supplier);
      _suppliers.insert(0, supplier);
      print('Fournisseur ajouté !');
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }
  void updateSupplier(Supplier supplier) async {
    try {
      await SupplierController.updateSupplier(supplier.id, supplier);
      int index = _suppliers.indexWhere((s) => s.id == supplier.id);
      if (index != -1) {
        _suppliers[index] = supplier;
        print('Fournisseur mis à jour !');
      }
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }
  void deleteSupplier(int id) async {
    try {
      await SupplierController.deleteSupplier(id);
      _suppliers.removeWhere((supplier) => supplier.id == id);
      print('Fournisseur supprimé !');
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }
  // Méthodes pour récupérer ajouter, supprimer ou mettre à jour des catégories
  Future<void> fetchCategories() async {
    _categories = await CategoryController.fetchCategories();
    notifyListeners();
  }
  // Récupérer les catégories par ID
  Category getCategoryById(int id) {
    return _categories.firstWhere((category) => category.id == id, orElse: () => Category.empty());
  }
  void addCategory(Category category) async {
    try {
      await CategoryController.addCategorie(category);
      _categories.insert(0, category);
      print('Catégorie ajoutée !');
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }
  void updateCategory(Category category) async {
    try {
      await CategoryController.updateCategory(category);
      int index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        print('Catégorie mise à jour !');
      }
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }
  void deleteCategory(int id) async {
    try {
      await CategoryController.deleteCategory(id);
      _categories.removeWhere((category) => category.id == id);
      print('Catégorie supprimée !');
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }
  // Méthodes pour récupérer, ajouter, supprimer ou mettre à jour des activités
  Future<void> fetchActivities() async {
    _activities = await HistoricalController.getAllHistorical();
    notifyListeners();
  }

  void addActivity(Activity activity) async {
    try {
      await HistoricalController.addActivity(activity);
      _activities.insert(0, activity);
      print('Activité ajoutée !');
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }
  void updateActivity(Activity activity) async {
    try {
      await HistoricalController.updateActivity(activity.id!, activity);
      int index = _activities.indexWhere((a) => a.id == activity.id);
      if (index != -1) {
        _activities[index] = activity;
        print('Activité mise à jour !');
      }
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }
  void deleteActivity(int id) async {
    try {
      await HistoricalController.deleteActivity(id);
      _activities.removeWhere((activity) => activity.id == id);
      print('Activité supprimée !');
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }

  void deleteAllActivities() async {
    try {
      await HistoricalController.deleteAllActivities();
      _activities.clear();
      print('Toutes les activités supprimées !');
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }

  // Méthodes pour récupérer, ajouter, supprimer ou mettre à jour des réductions
  Future<void> fetchDiscounts() async {
    _discounts = await DiscountController.getDiscounts();
    notifyListeners();
  }
  void addDiscount(Discount discount) async {
    try {
      await DiscountController.createDiscount(discount);
      _discounts.insert(0, discount);
      print('Réduction ajoutée !');
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }
  void updateDiscount(Discount discount) async {
    try {
      await DiscountController.updateDiscount(discount);
      int index = _discounts.indexWhere((d) => d.id == discount.id);
      if (index != -1) {
        _discounts[index] = discount;
        print('Réduction mise à jour !');
      }
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }
  void deleteDiscount(int id) async {
    try {
      await DiscountController.deleteDiscount(id);
      _discounts.removeWhere((discount) => discount.id == id);
      print('Réduction supprimée !');
    } catch (e) {
      print('Erreur: $e');
    }
    notifyListeners();
  }

  // Méthode pour vider les données
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
  // Méthode pour rafraîchir les données
  Future<void> refreshData() async {
    await _loadInitialData();
    notifyListeners();
  }
  // Méthode pour vérifier les privilèges
  bool hasPrivilege(String privilege) {
    return _myPrivileges?[privilege] ?? false;
  }
  // Méthode pour obtenir les privilèges disponibles
  Map<String, dynamic>? getAvailablePrivileges() {
    return _myPrivileges;
  }
  // Méthode pour obtenir le profil utilisateur
  Map<String, dynamic>? getUserProfile() {
    return _myPrivileges; // Assuming _myPrivileges contains user profile data
  }
  // Méthode pour obtenir le profil utilisateur
  Map<String, dynamic>? getUserProfileData() {
    return _userData;
  }
}