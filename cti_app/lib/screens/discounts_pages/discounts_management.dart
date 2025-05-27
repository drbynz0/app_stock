import 'package:cti_app/controller/category_controller.dart';
import 'package:flutter/material.dart';
import '/controller/discount_controller.dart';
import '/controller/product_controller.dart';
import '/models/discounts.dart';
import '/models/product.dart';
import 'add_discounts.dart';
import 'edit_discounts.dart';
import 'delete_discounts.dart';
import 'details_discount_screen.dart';


class DiscountsManagementScreen extends StatefulWidget {
  const DiscountsManagementScreen({super.key});

  @override
  State<DiscountsManagementScreen> createState() => _DiscountsManagementScreenState();
}

class _DiscountsManagementScreenState extends State<DiscountsManagementScreen> {

    List<Product> products = [];

  List<Discount> _discounts = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

    @override
  void initState() {
    super.initState();
    _loadOption();
  }

  Future<void> _loadOption() async {
    final fetchDiscounts = await DiscountController.getDiscounts();
    final fetchedProducts = await ProductController.fetchProducts();
    setState(() {
      _discounts = fetchDiscounts;
      products = fetchedProducts;
    });
  }

  void _addDiscount(Discount discount) {
    _loadOption();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Promotion Ajouté avec succès'), duration: const Duration(seconds: 3), backgroundColor: Colors.green,),
    );
  }

  void _editDiscount(Discount updatedDiscount) {
    _loadOption();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Promotion mise à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    Navigator.pop(context);
  }

  void _deleteDiscount(int? discountId) {
    final discount = Discount.getDiscountById(discountId);
    setState(() {
      bool inPromo = true;
      final discountController = DiscountController();
      discountController.applyDiscountToProduct(inPromo, discount.productId, discount.promotionPrice);
    });
  }

  List<Discount> get _filteredDiscounts {
    if (_searchQuery.isEmpty) return _discounts;
    return _discounts.where((discount) {
      return discount.productName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          CategoryController.fetchCategorieNameById(discount.productCategoryId).toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          discount.promotionPrice.toString().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotions en cours', style: TextStyle(fontSize: 20, color: Colors.white)),
        backgroundColor: const Color(0xFF003366),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher par nom ou catégorie...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _buildDiscountsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDiscountDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDiscountsList() {
    if (_filteredDiscounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/image/empty_promotion.png', height: 150),
            const SizedBox(height: 20),
            const Text(
              'Aucune promotion active',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text(
              'Appuyez sur le bouton + pour ajouter une promotion',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredDiscounts.length,
      itemBuilder: (context, index) {
        final discount = _filteredDiscounts[index];
        return _buildDiscountCard(discount);
      },
    );
  }

  Widget _buildDiscountCard(Discount discount) {
    final discountPercentage = ((discount.normalPrice - discount.promotionPrice) / discount.normalPrice * 100).round();
    Product product = products.firstWhere(
      (p) => p.id == discount.productId,
      orElse: () => Product.empty(),
    );

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsDiscountScreen(
              discount: discount,
              product: product, // Fonction à implémenter
            ),
          ),
        );
      },
      child: Card(
        color: const Color.fromARGB(255, 194, 224, 240),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              // Image du produit
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.images[0],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),

              // Détails du produit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom et pourcentage
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            discount.productName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '-$discountPercentage%',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category.name,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Prix
                    Wrap(
                      spacing: 16, // Espacement horizontal entre les éléments
                      runSpacing: 8, // Espacement vertical entre les lignes
                      children: [
                        Text(
                          '${discount.promotionPrice.toStringAsFixed(2)} MAD',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          '${discount.normalPrice.toStringAsFixed(2)} MAD',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),

              // Actions
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEditDiscountDialog(discount),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDiscountDialog(discount),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

    void _showAddDiscountDialog() {
    showDialog(
      context: context,
      builder: (context) => AddDiscountScreen(
        onAddDiscount: _addDiscount,
      ),
    );
  }

void _showEditDiscountDialog(Discount discount) {
  showDialog(
    context: context,
    builder: (context) => EditDiscountScreen(
      discount: discount,
      onEditDiscount: _editDiscount,
    ),
  );
}

  void _showDeleteDiscountDialog(Discount discount) {
    showDialog(
      context: context,
      builder: (context) => DeleteDiscountScreen(
        discount: discount,
        onDeleteDiscount: _deleteDiscount,
      ),
    );
  }
}