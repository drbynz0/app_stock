import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/controller/discount_controller.dart';
import '/models/discounts.dart';
import '/models/product.dart';
import '/controller/product_controller.dart';

class EditDiscountScreen extends StatefulWidget {
  final Discount discount;
  final Function(Discount) onEditDiscount;

  const EditDiscountScreen({
    super.key,
    required this.discount,
    required this.onEditDiscount,
  });

  @override
  State<EditDiscountScreen> createState() => _EditDiscountScreenState();
}

class _EditDiscountScreenState extends State<EditDiscountScreen> {
  List<Product> products = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _normalPriceController = TextEditingController();
  final TextEditingController _promotionPriceController = TextEditingController();
  
  Product _selectedProduct = Product.empty();
  DateTime? _startDate;
  DateTime? _endDate;
  double _discountPercentage = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadProducts();
  }

  void _initializeData() {
    _titleController.text = widget.discount.title;
    _descriptionController.text = widget.discount.description;
    _normalPriceController.text = widget.discount.normalPrice.toStringAsFixed(2);
    _promotionPriceController.text = widget.discount.promotionPrice.toStringAsFixed(2);
    _productNameController.text = widget.discount.productName;
    
    _calculateDiscount();
    
    final dates = widget.discount.validity.split(' - ');
    if (dates.length == 2) {
      _startDate = DateTime.tryParse(dates[0]);
      _endDate = DateTime.tryParse(dates[1]);
    }
  }

  Future<void> _loadProducts() async {
    try {
      final fetchedProducts = await ProductController.fetchProducts();
      final discountProduct = await ProductController.getProductById(widget.discount.productId);
      
      if (mounted) {
        setState(() {
          products = fetchedProducts;
          _selectedProduct = discountProduct;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur chargement produits: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _normalPriceController.dispose();
    _promotionPriceController.dispose();
    _productNameController.dispose();
    super.dispose();
  }

  void _calculateDiscount() {
    if (_normalPriceController.text.isNotEmpty && 
        _promotionPriceController.text.isNotEmpty) {
      final normalPrice = double.tryParse(_normalPriceController.text) ?? 0;
      final promoPrice = double.tryParse(_promotionPriceController.text) ?? 0;
      
      if (normalPrice > 0) {
        setState(() {
          _discountPercentage = ((normalPrice - promoPrice) / normalPrice * 100).roundToDouble();
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _saveDiscount() async {
    if (_formKey.currentState!.validate()) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: CircularProgressIndicator(
              color: Colors.blue.shade800,
            ),
          ),
        );

        final updateDiscount = widget.discount.copyWith(
          title: _titleController.text,
          validity: '${_startDate?.toLocal().toString().split(' ')[0]} - ${_endDate?.toLocal().toString().split(' ')[0]}',
          productId: _selectedProduct.id.toString(),
          productName: _productNameController.text,
          productCategoryId: _selectedProduct.category.id,
          normalPrice: double.tryParse(_normalPriceController.text) ?? 0.0,
          promotionPrice: double.tryParse(_promotionPriceController.text) ?? 0.0,
          description: _descriptionController.text,
        );

        final updatedDiscount = await DiscountController.updateDiscount(updateDiscount);

        if (mounted) {
          Navigator.pop(context);
          widget.onEditDiscount(updatedDiscount);
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildProductAutocomplete() {
    final theme = Provider.of<ThemeProvider>(context);
    return Autocomplete<Product>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Product>.empty();
        }
        return products.where((product) =>
            product.name.toString().toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      displayStringForOption: (Product option) => option.name,
      fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
        FocusNode focusNode, VoidCallback onFieldSubmitted) {
        if (textEditingController.text.isEmpty && _productNameController.text.isNotEmpty) {
          textEditingController.text = _productNameController.text;
        }
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Produit*',
            labelStyle: TextStyle(color: theme.textColor),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
            ),
            prefixIcon: Icon(Icons.shopping_cart, color: theme.iconColor),
            filled: true,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez sélectionner un produit';
            }
            return null;
          },
        );
      },
      onSelected: (Product selection) {
        setState(() {
          _productNameController.text = selection.name;
          _selectedProduct = selection;
          _normalPriceController.text = selection.price.toStringAsFixed(2);
        });
      },
      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<Product> onSelected,
          Iterable<Product> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: SizedBox(
              height: 200,
              width: MediaQuery.of(context).size.width - 90,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final Product option = options.elementAt(index);
                  return ListTile(
                    title: Text(option.name),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.dialogColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_offer, size: 32, color: theme.iconColor),
                        const SizedBox(width: 10),
                        Text(
                          'Modifier Promotion',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.titleColor,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: theme.iconColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 20),
                const SizedBox(height: 10),

                // Sélection du produit
                _buildProductAutocomplete(),
                const SizedBox(height: 16),

                // Titre de la promotion
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.title, color: theme.iconColor),
                    labelText: 'Titre de la promotion*',
                    labelStyle: TextStyle(color: theme.textColor),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
                    ),
                    filled: true,
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Ce champ est requis' : null,
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: theme.textColor),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
                    ),
                    filled: true,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Période de validité
                Text(
                  'Période de validité*',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.titleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            filled: true,
                          ),
                          child: Text(
                            _startDate != null 
                              ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                              : 'Date de début',
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('au'),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context, false),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            filled: true,
                          ),
                          child: Text(
                            _endDate != null 
                              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : 'Date de fin',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Prix et promotion
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _normalPriceController,
                        decoration: InputDecoration(
                          labelText: 'Prix normal*',
                          labelStyle: TextStyle(color: theme.textColor),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
                          ),
                          prefixText: 'MAD ',
                          prefixIcon: Icon(Icons.attach_money, color: Colors.blue.shade800),
                          filled: true,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateDiscount(),
                        validator: (value) => value?.isEmpty ?? true ? 'Ce champ est requis' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _promotionPriceController,
                        decoration: InputDecoration(
                          labelText: 'Prix promo*',
                          labelStyle: TextStyle(color: theme.textColor),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
                          ),
                          prefixText: 'MAD ',
                          prefixIcon: Icon(Icons.discount, color: Colors.blue.shade800),
                          filled: true,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateDiscount(),
                        validator: (value) => value?.isEmpty ?? true ? 'Ce champ est requis' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_discountPercentage > 0)
                  Text(
                    'Réduction: ${_discountPercentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: theme.titleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 24),

                // Bouton de validation
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveDiscount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.buttonColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Enregistrer les modifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}