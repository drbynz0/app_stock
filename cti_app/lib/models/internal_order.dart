class InternalOrder {
  final int? id;
  final String orderNum;
  final int? clientId;
  final String clientName;
  final TypeOrder typeOrder;
  final DateTime date;
  final PaymentMethod paymentMethod;
  final double totalPrice;
  double paidPrice;
  double remainingPrice;
  OrderStatus status;
  final String? description;
  final List<OrderItem> items;
  final List<Payments>? payments;
  final DateTime? created;
  final DateTime? updated;

  InternalOrder({
    this.id,
    required this.orderNum,
    required this.clientId,
    required this.clientName,
    required this.typeOrder,
    required this.date,
    required this.paymentMethod,
    required this.totalPrice,
    required this.paidPrice,
    required this.remainingPrice,
    this.description,
    required this.status,
    required this.items,
    this.payments,
    this.created,
    this.updated,
  });

  /// ➡️ Créer un Product depuis JSON
  factory InternalOrder.fromJson(Map<String, dynamic> json) {
    return InternalOrder(
      id: json['id'],
      orderNum: json['order_num'],
      clientId: json['client_id'],
      clientName: json['client_name'],
      typeOrder: _mapStringToTypeOrder(json['type']),      
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
        'client_id': clientId,
        'client_name': clientName,
        'type': typeOrder.name,
        'payment_method': paymentMethod.name,
        'total_price': totalPrice.toStringAsFixed(2),
        'total_paid': paidPrice.toStringAsFixed(2),
        'remaining_price': remainingPrice.toStringAsFixed(2),
        'description': description,
        'status': status.name,
        'items': items.map((item) => item.toJson()).toList(),
        'payments': payments?.map((payment) => payment.toJson()).toList(),
      };
    }

  static final List<InternalOrder> internalOrderList = [

  ];


  static List<InternalOrder> getInternalOrderList() {
    return internalOrderList;
  }

  static void addInternalOrder(InternalOrder order) {
    internalOrderList.insert(0, order);
  }

  static void removeInternalOrder(InternalOrder order) {
    internalOrderList.remove(order);
  }

  static InternalOrder getInternalOrderById(String orderNum) {
    return internalOrderList.firstWhere((order) => order.orderNum == orderNum, orElse: () => InternalOrder.empty());
  }

    static InternalOrder empty() {
    return InternalOrder(
      id: 0,
      orderNum: '',
      clientId: 0,
      clientName: '',
      typeOrder: TypeOrder.online,
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
   int quantity;
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

enum TypeOrder {
  online,
  inStore,
}

TypeOrder _mapStringToTypeOrder(String source) {
  switch (source) {
    case 'online':
      return TypeOrder.online;
    case 'inStore':
    return TypeOrder.inStore;
    default:
      throw Exception('TypeOrder inconnu : $source');
  }
}

class Payments {
  final int? id;
  final InternalOrder order;
  final double totalPaid;
  final PaymentMethod paymentMethod;
  final String? paidAt;
  final String? note;

  Payments({
    this.id,
    required this.order,
    required this.totalPaid,
    required this.paymentMethod,
    this.paidAt,
    this.note,
});

  factory Payments.fromJson(Map<String, dynamic> json) {
    return Payments(
      id: json['id'],
        order: json['order'],
        totalPaid: double.parse(json['amount']),
        paymentMethod: _mapStringToPayment(json['payment_method']),
        paidAt: json['date'],
        note: json['description'] ?? '',
      );
    }

    Map<String, dynamic> toJson() {
      return {
        'order': order,
        'amount': totalPaid.toString(),
        'payment_method': paymentMethod.name,
        'date': paidAt,
        'description': note,
      };
    }


}