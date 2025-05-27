import 'package:cti_app/controller/facture_controller.dart';

import 'internal_order.dart';
import 'external_order.dart';

class FactureClient {
  final int? id;
  final String ref;
  final String orderNum;
  final int clientId;
  final String clientName;
  final double amount;
  final String date;
  final String description;
  final bool isInternal;
  bool isPaid;

  FactureClient({
    this.id,
    required this.ref,
    required this.orderNum,
    required this.clientId,
    required this.clientName,
    required this.amount,
    required this.date,
    required this.description,
    required this.isInternal,
    required this.isPaid,
  });

  // Liste dynamique pour les nouvelles factures internes
  static final List<FactureClient> _internalFactures = [];

  get clientAddress => null;

  factory FactureClient.fromJson(Map<String, dynamic> json) {
  return FactureClient(
    id: json['id'],
    ref: json['ref'],
    orderNum: json['order_num'],
    clientId: json['client_id'],
    clientName: json['client_name'],
    amount: (json['amount'] as num).toDouble(),
    date: json['date'],
    description: json['description'],
    isInternal: json['is_internal'],
    isPaid: json['is_paid'],
  );
}

Map<String, dynamic> toJson() {
  return {
    'id': id,
    'ref': ref,
    'order_num': orderNum,
    'client_id': clientId,
    'client_name': clientName,
    'amount': amount,
    'date': date,
    'description': description,
    'is_internal': isInternal,
    'is_paid': isPaid,
  };
}


  static List<FactureClient> getInternalFactures() {
    return _internalFactures;
  }

  static void addInternalFacture(FactureClient facture) {
    _internalFactures.insert(0, facture);
  }

  static void addFactureForOrder(InternalOrder order) async {
  final newFacture = FactureClient(
    ref: 'FI-${DateTime.now().millisecondsSinceEpoch}',
    orderNum: order.orderNum,
    clientId: order.clientId ?? 0,
    clientName: order.clientName,
    amount: order.totalPrice,
    date: '${order.date.day}/${order.date.month}/${order.date.year}',
    description: order.description ?? 'Facture pour commande ${order.id}',
    isPaid: order.paidPrice >= order.totalPrice, isInternal: true,
  );
  
  // Ajouter la facture à votre liste de factures
  await FactureClientController.addFacture(newFacture);
}

  static void updateFactureForOrder(InternalOrder order) async {
    final oldFacture = await getFactureByOrderNum(order.orderNum);
    final newFacture = FactureClient(
      id: oldFacture.id,
      ref: oldFacture.ref,
      orderNum: order.orderNum,
      clientId: order.clientId!,
      clientName: order.clientName,
      amount: order.totalPrice,
      date: '${order.date.day}/${order.date.month}/${order.date.year}',
      description: order.description ?? 'Facture pour commande ${order.id}',
      isPaid: order.paidPrice >= order.totalPrice, isInternal: true,
    );
    
    // Ajouter la facture à votre liste de factures
    await FactureClientController.updateFacture(newFacture);
  }

    static Future<FactureClient> getFactureByOrderNum(String orderNum) async {
      final factures = await FactureClientController.getFactures();
      return factures.firstWhere(
        (f) => f.orderNum == orderNum,
        orElse: () => FactureClient.empty(),
      );
    }

  static FactureClient empty() {
    return FactureClient(
      ref: '',
        orderNum: '',
        clientId: 0,
        clientName: '',
        amount: 0,
        date: '',
        description: '',
        isInternal: false,
        isPaid: false,

      // Initialize other required fields with default values
    );
  }

  static FactureClient getInternalFactureByOrderId(String orderNum) {
    return _internalFactures.firstWhere((facture) => facture.orderNum == orderNum, orElse: () => throw Exception('Facture not found'));
  }
}

class FactureFournisseur {
  final int? id;
  final String ref;
  final String orderNum;
  final int supplierId;
  final String supplierName;
  final double amount;
  final String date;
  final String description;
  final bool isInternal;
  bool isPaid;

  FactureFournisseur({
    this.id,
    required this.ref,
    required this.orderNum,
    required this.supplierId,
    required this.supplierName,
    required this.amount,
    required this.date,
    required this.description,
    required this.isInternal,
    required this.isPaid,
  });

  // Liste dynamique
  static final List<FactureFournisseur> _externalFactures = [];

factory FactureFournisseur.fromJson(Map<String, dynamic> json) {
  return FactureFournisseur(
    id: json['id'],
    ref: json['ref'],
    orderNum: json['order_num'],
    supplierId: json['supplier_id'],
    supplierName: json['supplier_name'],
    amount: (json['amount'] as num).toDouble(),
    date: json['date'],
    description: json['description'],
    isInternal: json['is_internal'],
    isPaid: json['is_paid'],
  );
}

Map<String, dynamic> toJson() {
  return {
    'ref': ref,
    'order_num': orderNum,
    'supplier_id': supplierId,
    'supplier_name': supplierName,
    'amount': amount,
    'date': date,
    'description': description,
    'is_internal': isInternal,
    'is_paid': isPaid,
  };
}


  static List<FactureFournisseur> getExternalFactures() {
    return _externalFactures;
  }

  static void addExternalFacture(FactureFournisseur facture) {
    _externalFactures.insert(0, facture);
  }

    static void addFactureForOrder(ExternalOrder order) async {
      final newFacture = FactureFournisseur(
        ref: 'FE-${DateTime.now().millisecondsSinceEpoch}',
        orderNum: order.orderNum,
        supplierId: order.supplierId!,
        supplierName: order.supplierName,
        amount: order.totalPrice,
        date: '${order.date.day}/${order.date.month}/${order.date.year}',
        description: order.description ?? 'Facture pour commande ${order.id}',
        isPaid: order.paidPrice >= order.totalPrice, isInternal: true,
      );
      
      // Ajouter la facture à votre liste de factures
      await FactureSupplierController.addFacture(newFacture);
    }

  static void updateFactureForOrder(ExternalOrder order) async {
    final oldFacture = await getFactureByOrderNum(order.orderNum);
    final newFacture = FactureFournisseur(
      id: oldFacture.id,
      ref: oldFacture.ref,
      orderNum: order.orderNum,
      supplierId: order.supplierId!,
      supplierName: order.supplierName,
      amount: order.totalPrice,
      date: '${order.date.day}/${order.date.month}/${order.date.year}',
      description: order.description ?? 'Facture pour commande ${order.id}',
      isPaid: order.paidPrice >= order.totalPrice, isInternal: true,
    );
    
    // Ajouter la facture à votre liste de factures
    await FactureSupplierController.updateFacture(newFacture);
  }

    static Future<FactureFournisseur> getFactureByOrderNum(String orderNum) async {
      final factures = await FactureSupplierController.getFactures();
      return factures.firstWhere(
        (f) => f.orderNum == orderNum,
        orElse: () => FactureFournisseur.empty(),
      );
    }

  static FactureFournisseur empty() {
    return FactureFournisseur(
      ref: '',
        orderNum: '',
        supplierId: 0,
        supplierName: '',
        amount: 0,
        date: '',
        description: '',
        isInternal: false,
        isPaid: false,

      // Initialize other required fields with default values
    );
  }
}
