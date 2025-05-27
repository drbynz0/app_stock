class DeliveryNote {
  final int? id;
  final String noteNumber;
  final DateTime? date;
  final int? clientId;
  final String clientName;
  final String clientAddress;
  final List<DeliveryItem> items;
  final String preparedBy;
  final String? comments;
  final String orderNum;

  DeliveryNote({
    this.id,
    required this.noteNumber,
    required this.date,
    this.clientId,
    required this.clientName,
    required this.clientAddress,
    required this.items,
    required this.preparedBy,
    this.comments,
    required this.orderNum, // Assurez-vous que ce champ est aussi requis ici
  });


  factory DeliveryNote.fromJson(Map<String, dynamic> json) {
    return DeliveryNote(
      id: json['id'],
      noteNumber: json['note_number'],
      date: DateTime.parse(json['date']),
      clientId: json['client_id'],
      clientName: json['client_name'],
      clientAddress: json['client_address'],
      items: (json['items'] as List)
          .map((item) => DeliveryItem.fromJson(item))
          .toList(),
      preparedBy: json['prepared_by'],
      comments: json['comments'],
      orderNum: json['order_num'],
    );
  }

  Map<String, dynamic> toJson() => {
        'note_number': noteNumber,
        'date': date.toString(),
        'client_id': clientId,
        'client_name': clientName,
        'client_address': clientAddress,
        'items': items.map((e) => e.toJson()).toList(),
        'prepared_by': preparedBy,
        'comments': comments,
        'order_num': orderNum,
      };

  double get totalAmount =>
      items.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));

   static final List<DeliveryNote> _deliveryNotes = [];

  static void addDeliveryNote(DeliveryNote note) {
    _deliveryNotes.insert(0, note);
  }

  static List<DeliveryNote> getDeliveryNotes() {
    return _deliveryNotes;
  }

  static DeliveryNote getDeliveryNotesByOrderId(String orderId) {
    return _deliveryNotes.firstWhere((d) => d.orderNum == orderId, orElse: () => DeliveryNote.empty());
  }

  static DeliveryNote empty() {
    return DeliveryNote(
      noteNumber: '0',
      date: DateTime.now(),
      clientId: 0,
      clientName: '',
      clientAddress: '',
      items: [],
      preparedBy: '',
      orderNum: '',
      // Initialize other required fields with default values
    );
  }
}

class DeliveryItem {
  final String productCode;
  final String description;
  final int quantity;
  final double unitPrice;

  DeliveryItem({
    required this.productCode,
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  factory DeliveryItem.fromJson(Map<String, dynamic> json) {
    return DeliveryItem(
      productCode: json['product_code'],
      description: json['description'],
      quantity: json['quantity'],
      unitPrice: json['unit_price'],
    );
  }

  Map<String, dynamic> toJson() => {
        'product_code': productCode,
        'description': description,
        'quantity': quantity,
        'unit_price': unitPrice,
      };

  String get reference => productCode;
}
