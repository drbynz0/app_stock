class ProductSales {
  final String productId;
  final String productName;
  final int quantitySold;
  final double totalAmount;
  final String? imageUrl;

  ProductSales({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.totalAmount,
    this.imageUrl,
  });
}