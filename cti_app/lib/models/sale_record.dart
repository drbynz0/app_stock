import 'internal_order.dart';
import 'external_order.dart';

abstract class SaleRecord {
  DateTime get date;
  double get amount;
}

// Adapters pour convertir vos classes existantes
class InternalOrderRecord extends SaleRecord {
  final InternalOrder order;

  InternalOrderRecord(this.order);

  @override
  DateTime get date => order.date;

  @override
  double get amount => order.paidPrice;
}

class ExternalOrderRecord extends SaleRecord {
  final ExternalOrder order;

  ExternalOrderRecord(this.order);

  @override
  DateTime get date => order.date;

  @override
  double get amount => order.paidPrice;
}