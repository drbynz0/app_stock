import 'package:cti_app/models/product.dart';

class Supplier {
  final int? id;
  final String ice;
  final String nameRespo;
  final String nameEnt;
  final String email;
  final String phone;
  final String address;
  final List<Product> products;


  Supplier({
    this.id,
    required this.ice,
    required this.nameRespo,
    required this.nameEnt,
    required this.email,
    required this.phone,
    required this.address,
    required this.products,
  });

  // Méthode statique pour obtenir la liste initiale
  static List<Supplier> listSuppliers = [
      Supplier(
        ice: '1344343439876',
        nameRespo: 'Mohamed Kassi',
        nameEnt: 'MOMO',
        email: 'contact@kassientreprise.ma',
        phone: '0522445566',
        address: 'Zone Industrielle, Casablanca',
        products: [],
      ),
      Supplier(
        ice: '2',
        nameRespo: 'Fatima Zahra',
        nameEnt: 'FATI',
        email: 'fz@materiaux-premium.ma',
        phone: '0522889977',
        address: 'Ain Sebaa, Casablanca',
        products: [],
      ),
      Supplier(
        ice: '3',
        nameRespo: 'Karim El Fassi',
        nameEnt: 'KARI',
        email: 'k.fassi@batimetal.ma',
        phone: '0522334455',
        address: 'Sidi Maarouf, Casablanca',
        products: [],
      ),
    ];

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] ?? 0,
      ice: json['ice'] ?? '',
      nameRespo: json['name_respo'] ?? '',
      nameEnt: json['name_ent'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      products: (json['products_details'] as List<dynamic>?)
        ?.map((item) => Product.fromJson(item))
        .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ice': ice,
      'name_respo': nameRespo,
      'name_ent': nameEnt,
      'email': email,
      'phone': phone,
      'address': address,
      'products': products.map((p) => p.id).toList(),
    };
  }

  Supplier copyWith({
    String? ice,
    String? nameRespo,
    String? nameEnt,
    String? email,
    String? phone,
    String? address,
    List<Product>? products,
    String? categorie
  }) {
    return Supplier(
      ice: ice ?? this.ice,
      nameRespo: nameRespo ?? this.nameRespo,
      nameEnt: nameEnt ?? this.nameEnt,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      products: products ?? this.products,
    );
  }

  static void addSupplier(Supplier newSupplier) {
    listSuppliers.insert(0, newSupplier);
  }

  static Supplier getSupplierById(String id) {
    return listSuppliers.firstWhere((client) => client.ice == id, orElse: () => Supplier.empty());
  }


  static Supplier empty() {
    return Supplier(
      ice: '0',
      nameRespo: '',
      nameEnt: '',
      email: '',
      phone: '',
      address: '',
      products: [],
    );
  }
}