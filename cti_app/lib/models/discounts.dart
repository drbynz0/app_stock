class Discount {
  final int? id;
  final String title;
  final String? dateDebut;
  final String? dateFin;
  final String validity;
  final int productId;
  final String productName;
  final int? productCategoryId;
  String? images;
  final double normalPrice;
  final double promotionPrice;
  String description;

  Discount({
    this.id,
    required this.title,
    required this.dateDebut,
    required this.dateFin,
    required this.validity,
    required this.productId,
    required this.productCategoryId,
    this.images,
    required this.productName,
    required this.normalPrice,
    required this.promotionPrice,
    required this.description,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      dateDebut: json['date_debut'] ?? '',
      dateFin: json['date_fin'] ?? '',
      validity: json['validity'] ?? '',
      productName: json['product_name'] ?? '',
      productId: json['product_id'] ?? '',
      productCategoryId: json['product_category'] ?? '',
      images: json['images'] ?? '',
      normalPrice: json['normal_price']?.toDouble() ?? 0.0,
      promotionPrice: json['promotion_price']?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date_debut': dateDebut,
      'date_fin': dateFin,
      'validity': validity,
      'product_id': productId,
      'product_name': productName,
      'product_category': productCategoryId,
      'normal_price': normalPrice,
      'promotion_price': promotionPrice,
      'images': images,
      'description': description,
    };
  }
  Discount copyWith({
    int? id,
    String? title,
    String? dateDebut,
    String? dateFin,
    String? validity,
    String? productName,
    double? normalPrice,
    double? promotionPrice, required String productId, required int? productCategoryId, required String description,
  }) {
    return Discount(
      id: id ?? this.id,
      title: title ?? this.title,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      validity: validity ?? this.validity,
      productId: int.parse(productId),
      productName: productName ?? this.productName,
      productCategoryId: productCategoryId ?? this.productCategoryId,
      images: images,
      normalPrice: normalPrice ?? this.normalPrice,
      promotionPrice: promotionPrice ?? this.promotionPrice,
      description: description,
    );
  }
  static Discount empty() {
    return Discount(
      id: 0,
      title: '',
      validity: '',
      dateDebut: '',
      dateFin: '',
      productId: 0,
      productCategoryId: 0,
      images: '',
      productName: '',
      normalPrice: 0.0,
      promotionPrice: 0.0,
      description: '',
    );
  }
  static final List<Discount> discountList = [];

 // static final List<Discount> _discountList = [];

  static List<Discount> getDiscountList() {
    return discountList;
  }

  void addDiscount(Discount newDiscount) {
    discountList.insert(0, newDiscount);
  }

  static Discount getDiscountById(int? id) {
    return discountList.firstWhere((element) => element.id == id, orElse: () => Discount.empty());
  }

  static Discount getDiscountByProductId(String productId) {
    try {
      // ignore: unrelated_type_equality_checks
      return discountList.firstWhere((discount) => discount.productId == productId);
    } catch (e) {
      throw Exception('Aucune promotion trouvée pour ce produit.');
    }
  }

  static List<Discount> getDiscountListByValidity(String validity) {
    return getDiscountList().where((discount) => discount.validity == validity).toList();
  }

}

  
