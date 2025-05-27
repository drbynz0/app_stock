import 'package:cti_app/controller/category_controller.dart';
import 'package:cti_app/controller/customer_controller.dart';
import 'package:cti_app/controller/external_orders_controller.dart';
import 'package:cti_app/controller/historical_controller.dart';
import 'package:cti_app/controller/internal_orders_controller.dart';
import 'package:cti_app/controller/login_controller.dart';
import 'package:cti_app/controller/product_controller.dart';
import 'package:cti_app/controller/supplier_controller.dart';
import 'package:cti_app/controller/user_controller.dart';
import 'package:cti_app/models/activity.dart';
import 'package:cti_app/models/category.dart';
import 'package:flutter/material.dart';
import '../models/client.dart';
import '../models/external_order.dart';
import '../models/internal_order.dart';
import '../models/supplier.dart';
import '../models/product.dart';

class AppData extends ChangeNotifier {
  List<Client> _clients = [];
  List<ExternalOrder> _externalOrders = [];
  List<InternalOrder> _internalOrders = [];
  List<Supplier> _suppliers = [];
  List<Product> _products = [];
  List<Category> _categories = [];
  String _isAdmin = '';
  Map<String, dynamic>? _myPrivileges = {};
  List<Activity> _activities = [];


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
    _suppliers = await  SupplierController.getSuppliers();
    _isAdmin = AuthController.isadmin!;
    _myPrivileges = await UserController.fetchUserPrivileges();
    _activities = await HistoricalController.getAllHistorical();
    notifyListeners();
  }

  // Getters
  List<Client> get clients => _clients;
  List<Product> get products => _products;
  List<Category> get categories => _categories;
  List<ExternalOrder> get externalOrders => _externalOrders;
  List<InternalOrder> get internalOrders => _internalOrders;
  List<Supplier> get suppliers => _suppliers;
  String get isAdmin => _isAdmin;
  Map<String, dynamic>? get myPrivileges => _myPrivileges;
  List<Activity> get activities => _activities;
}