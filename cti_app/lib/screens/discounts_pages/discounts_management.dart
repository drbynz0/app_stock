// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:cti_app/controller/discount_controller.dart';
import 'package:cti_app/models/category.dart';
import 'package:cti_app/services/app_data_service.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  List<Discount> _discounts = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  Map<String, dynamic>? myPrivileges = {};
  Map<String, dynamic>? userData = {};

  @override
  void initState() {
    super.initState();
    _loadOption();
  }

  Future<void> _loadOption() async {
    final appData = Provider.of<AppData>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        appData.refreshDataService(context);
      }
    });

    if (appData.discounts.isEmpty) {
      await appData.fetchDiscounts();
    }
    if (appData.products.isEmpty) {
      await appData.fetchProducts();
    }

    myPrivileges = appData.myPrivileges;
    userData = appData.userData;

    if (mounted) {
      setState(() {
        _discounts = appData.discounts;
      });
    }
  }

  void _addDiscount(Discount discount) async {
    final appData = Provider.of<AppData>(context, listen: false);
    await appData.fetchDiscounts();
    await _loadOption();
    Navigator.pop(context);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Promotion ajoutée avec succès'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _editDiscount(Discount updatedDiscount) async {
    final appData = Provider.of<AppData>(context, listen: false);
    await appData.fetchDiscounts();
    await _loadOption();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Promotion mise à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _deleteDiscount(int? discountId) async {
    final appData = Provider.of<AppData>(context, listen: false);
    final discount = _discounts.firstWhere((d) => d.id == discountId);
    
    setState(() {
      bool inPromo = true;
      final discountController = DiscountController();
      discountController.applyDiscountToProduct(inPromo, discount.productId, discount.promotionPrice);
    });
    
    await appData.fetchDiscounts();
    await _loadOption();
  }

  List<Discount> get _filteredDiscounts {
    if (_searchQuery.isEmpty) return _discounts;
    return _discounts.where((discount) {
      final Category category = AppData().getCategoryById(discount.productCategoryId!);
      return discount.productName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          category.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          discount.promotionPrice.toString().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    //final theme = Provider.of<ThemeProvider>(context);
    final appData = Provider.of<AppData>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotions en cours', style: TextStyle(fontSize: 20, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher par nom ou catégorie...',
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _buildDiscountsList(appData),
          ),
        ],
      ),
      floatingActionButton: ((userData?['is_staff'] ?? false) || (myPrivileges?['add_discount'] ?? false))
          ? FloatingActionButton(
              onPressed: () => _showAddDiscountDialog(),
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildDiscountsList(AppData appData) {
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
        return _buildDiscountCard(appData, discount);
      },
    );
  }

  Widget _buildDiscountCard(AppData appData, Discount discount) {
    final theme = Provider.of<ThemeProvider>(context);
    final discountPercentage = ((discount.normalPrice - discount.promotionPrice) / discount.normalPrice * 100).round();
    final product = appData.products.firstWhere(
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
              product: product,
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        color: theme.secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
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
              if ((userData?['is_staff'] ?? false) || (myPrivileges?['edit_discount'] ?? false) || (myPrivileges?['delete_discount'] ?? false))
                Column(
                  children: [
                    if ((userData?['is_staff'] ?? false) || (myPrivileges?['edit_discount'] ?? false))
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditDiscountDialog(discount),
                      ),
                    if ((userData?['is_staff'] ?? false) || (myPrivileges?['delete_discount'] ?? false))
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