import 'package:cti_app/models/category.dart';

class Product {
  final int? id;
  final String name;
  int variants;
  String marque;
  final String code;
  final Category category;
  int stock;
  bool available;
  final double price;
  double? promoPrice;
  final String? description;
  bool onPromo;
  final List<String> images;
  final DateTime? createdAt;
  DateTime? updatedAt;



  Product({
    this.id = 0,
    required this.name,
    required this.variants,
    required this.marque,
    required this.code,
    required this.category,
    required this.stock,
    required this.available,
    required this.price,
    this.promoPrice,
    this.description,
    required this.onPromo,
    required this.images,
    this.createdAt,
    this.updatedAt,
  });

  get sellingPrice => null;

  /// ➡️ Créer un Product depuis JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      variants: json['variants']?? '',
      marque: json['marque'] ?? '',
      code: json['code'] ?? '',
      category: Category.fromJson(json['category']),    
      stock: json['stock'],
      available: json['available'],
      price: double.parse(json['price']),
      promoPrice: json['promo_price'] != null ? double.tryParse(json['promo_price']) : null,
      description: json['description'],
      onPromo: json['on_promo'],
      images: (json['images'] as List<dynamic>).map((img) => img['image'].toString()).toList(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// ➡️ Convertir Product en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id?.toString(),
      'name': name,
      'marque': marque,
      'category_id': category.id,
      'variants': variants,
      'code': code,
      'stock': stock,
      'available': available,
      'price': price.toString(),
      'promo_price': promoPrice,
      'description': description,
      'on_promo': onPromo,
      'created_at': createdAt.toString(),
      'updated_at': updatedAt.toString(),
      // Note: 'category' est géré séparément dans createProductWithImages
      // Note: 'images' est géré séparément via MultipartFile
    };
  }

  Product copyWith({
    int? id,
    String? name,
    int? variants,
    String? marque,
    String? code,
    Category? category,
    int? stock,
    bool? available,
    double? price,
    double? promoPrice,
    String? description,
    bool? onPromo,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    }) {
      return Product(
        id: id ?? this.id,
        name: name ?? this.name,
        variants: variants ?? this.variants,
        marque: marque ?? this.marque,
        code: code ?? this.code,
        category: category ?? this.category,
        stock: stock ?? this.stock,
        available: available ?? this.available,
        price: price ?? this.price,
        promoPrice: promoPrice ?? this.promoPrice,
        description: description ?? this.description,
        onPromo: onPromo ?? this.onPromo,
        images: images ?? this.images,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  }

    static Product empty() {
    return Product(
      code: '',
      name: '',
      variants: 0,
      category: Category.empty(),
      available: false,
      stock: 0,
      price: 0.0,
      description: '',
      onPromo: false,
      images: [],
      marque: '',
    );
  }
}