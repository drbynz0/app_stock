class ExternalOrder {
  final int? id;
  final String orderNum;
  final int? supplierId;
  final String supplierName;
  final DateTime date;
  final PaymentMethod paymentMethod;
  final double totalPrice;
  final double paidPrice;
  final double remainingPrice;
  final String? description;
  OrderStatus status;
  final List<OrderItem> items;
  final DateTime? created;
  final DateTime? updated;

    static final List<ExternalOrder> externalOrderList = [
  ];

  ExternalOrder({
    this.id,
    required this.orderNum,
    required this.supplierId,
    required this.supplierName,
    required this.date,
    required this.paymentMethod,
    required this.totalPrice,
    required this.paidPrice,
    required this.remainingPrice,
    this.description,
    required this.status,
    required this.items,
    this.created,
    this.updated,
  });

  /// ➡️ Créer un Product depuis JSON
  factory ExternalOrder.fromJson(Map<String, dynamic> json) {
    return ExternalOrder(
      id: json['id'],
      orderNum: json['order_num'],
      supplierId: json['supplier_id'],
      supplierName: json['supplier_name'],
      date: DateTime.parse(json['date']),
      paymentMethod: _mapStringToPayment(json['payment_method']),
      totalPrice: double.parse(json['total_price']),
      paidPrice: double.parse(json['total_paid']),
      remainingPrice: double.parse(json['remaining_price']),
      status: _mapStringToOrderStatus(json['status']),
      items: json['items'] != null
        ? (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList()
        : [],
      description: json['description'],
      created: DateTime.parse(json['created_at']),
      updated: DateTime.parse(json['updated_at']),
    );
  }

    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'order_num': orderNum,
        'supplier_id': supplierId,
        'supplier_name': supplierName,
        'payment_method': paymentMethod.name,
        'total_price': totalPrice.toStringAsFixed(2),
        'total_paid': paidPrice.toStringAsFixed(2),
        'remaining_price': remainingPrice.toStringAsFixed(2),
        'description': description,
        'status': status.name,
        'items': items.map((item) => item.toJson()).toList(),
      };
    }

  static List<ExternalOrder> getExternalOrderList() {
    return externalOrderList;
  }

  static void addExternalOrder(ExternalOrder order) {
    externalOrderList.insert(0, order);
  }

  static void removeExternalOrder(ExternalOrder order) {
    externalOrderList.remove(order);
  }

  static ExternalOrder getExternalOrderById(int id) {
    return externalOrderList.firstWhere((order) => order.id == id, orElse: () => ExternalOrder.empty());
  }

  static ExternalOrder empty() {
    return ExternalOrder(
      id: 0,
      orderNum: '',
      supplierId: 0,
      supplierName: '',
      date: DateTime.now(),
      paymentMethod: PaymentMethod.cash,
      totalPrice: 0.0,
      paidPrice: 0.0,
      remainingPrice: 0.0,
      status: OrderStatus.pending,
      items: [],
      // Add other required fields with default values
    );
    }
  
}

class OrderItem {
  int? id;
  final int? productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double unitPrice;
  final String productRef;

  OrderItem({
    this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.unitPrice,
    required this.productRef,
  });

  get description => null;

    factory OrderItem.fromJson(Map<String, dynamic> json) {
      return OrderItem(
        id: json['id'],
        productId: json['product'],
        productName: json['product_name'],
        productImage: json['product_image'],
        quantity: json['quantity'],
        unitPrice: double.parse(json['price']),
        productRef: json['product_ref'],
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'product': productId,
        'product_ref': productRef,
        'product_name': productName,
        'product_image': productImage,
        'quantity': quantity,
        'price': unitPrice.toStringAsFixed(2),
      };
    }
}

enum OrderStatus {
  pending,
  processing,
  toPay,
  completed,
  cancelled,
}

OrderStatus _mapStringToOrderStatus(String source) {
  switch (source) {
    case 'pending':
    return OrderStatus.pending;
    case 'processing':
    return OrderStatus.processing;
    case 'toPay':
    return OrderStatus.toPay;
    case 'completed':
    return OrderStatus.completed;
    case 'cancelled':
    return OrderStatus.cancelled;
    default :
      throw Exception('Statut de commande inconnu : $source');
  }
}

enum PaymentMethod {
  cash,
  card,
  virement,
  cheque,
}

PaymentMethod _mapStringToPayment(String source) {
  switch (source) {
    case 'cash':
      return PaymentMethod.cash;
    case 'card':
      return PaymentMethod.card;
    case 'virement':
      return PaymentMethod.virement;
    case 'cheque':
      return PaymentMethod.cheque;
    default:
      throw Exception('Methode de paiement inconnu : $source');
  }
}