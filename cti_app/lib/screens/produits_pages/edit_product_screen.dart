// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '/controller/product_controller.dart';
import '/models/category.dart';
import '/services/activity_service.dart';
import '/services/app_data_service.dart';
import '/widgets/build_category.dart';
import 'dart:io';
import '../../models/product.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  final Function(Product) onProductUpdated;

  const EditProductScreen({
    super.key,
    required this.product,
    required this.onProductUpdated,
  });

  @override
  EditProductScreenState createState() => EditProductScreenState();
}

class EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _variantController;
  late final TextEditingController _marqueController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _categoryController;
  late final TextEditingController _descriptionController;



  late Category productCategory;
  late List<Category> categories;
  Category _selectedCategory = Category.empty();

  late List<File?> _newImageFiles; 
  late List<String> _currentImageUrls;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _variantController = TextEditingController(text: widget.product.variants.toString());
    _descriptionController = TextEditingController(text: widget.product.description);
    _marqueController = TextEditingController(text: widget.product.marque);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _stockController = TextEditingController(text: widget.product.stock.toString());
    _categoryController = TextEditingController();
    productCategory = Category.empty();
    categories = [];

    //initialiser les images actuelles
    _newImageFiles = List<File?>.filled(4, null); 
    _currentImageUrls = List.from(widget.product.images);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appData = Provider.of<AppData>(context);
    categories = appData.categories;
    productCategory = widget.product.category;
    _categoryController.text = productCategory.name.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _variantController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _marqueController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(int index) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImageFiles[index] = File(pickedFile.path);
      });
    }
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return SizedBox.expand( // <-- Prend tout l'espace alloué
          child: _buildImageItem(index),
        );      
      },
    );
  }

 Widget _buildImageItem(int index) {
  final hasNewImage = _newImageFiles[index] != null;
  final hasCurrentImage = index < _currentImageUrls.length && _currentImageUrls[index].isNotEmpty;

  return GestureDetector(
    onTap: () => _pickImage(index),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade800),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasNewImage)
            _buildImagePreview(_newImageFiles[index]!)
          else if (hasCurrentImage)
            _buildNetworkImage(index)
          else
            _buildPlaceholderIcon(),
          if (hasCurrentImage && !hasNewImage)
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _removeImage(index),
              ),
            ),
        ],
      ),
    ),
  );
}

Widget _buildImagePreview(File file) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.file(file, fit: BoxFit.cover),
  );
}

  Widget _buildNetworkImage(int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        _currentImageUrls[index],
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      if (_newImageFiles[index] != null) {
        _newImageFiles[index] = null;
      } else {
        _currentImageUrls.removeAt(index);
      }
    });
  }

  Widget _buildPlaceholderIcon() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, size: 30, color: Colors.blue),
        SizedBox(height: 4),
        Text('Image'),
      ],
    );
  }

void _submitForm() async {
  if (!_formKey.currentState!.validate()) return;

  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    List<File> imagesToUpload = _handleImageUpdates();
    
    if (imagesToUpload.isEmpty && _currentImageUrls.isEmpty) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez ajouter au moins une image'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final updatedProduct = Product(
      id: widget.product.id,
      name: _nameController.text.trim(),
      variants: int.parse(_variantController.text),
      marque: _marqueController.text.trim(),
      price: double.parse(_priceController.text),
      stock: int.parse(_stockController.text),
      category: _selectedCategory,
      code: widget.product.code,
      description: _descriptionController.text.trim(),
      available: int.parse(_stockController.text) > 0,
      onPromo: widget.product.onPromo,
      promoPrice: widget.product.promoPrice,
      images: _currentImageUrls, // Conserver les URLs existantes
      createdAt: widget.product.createdAt,
      updatedAt: DateTime.now(),
    );

    await ProductController.updateProduct(updatedProduct, imagesToUpload);
    
    if (mounted) {
      Navigator.pop(context);
      widget.onProductUpdated(updatedProduct);
      Provider.of<ActivityService>(context, listen: false).addActivity(
        "Modification du produit : ${updatedProduct.name}",
        'edit',
      );
    }
  } catch (e) {
    if (mounted) {
      Navigator.pop(context);
      print(e);
    }
  }
}

  List<File> _handleImageUpdates() {
    final List<File> resultImages = [];
    
    // 1. Ajouter les nouvelles images sélectionnées
    for (var file in _newImageFiles) {
      if (file != null) {
        resultImages.add(file);
      }
    }
    
    // 2. Vérifier que nous avons au moins une image
    if (resultImages.isEmpty && _currentImageUrls.isEmpty) {
      return [];
    }
    
    return resultImages;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 3,
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nouvel en-tête avec icône
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue.shade800, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          'Modifier Produit',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 24),
                
                // Section images avec nouveau style
                Text(
                  'Images du produit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                _buildImageGrid(),
                const SizedBox(height: 24),

                // Champs de formulaire avec nouveau style
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom du produit',
                    floatingLabelStyle: TextStyle(color: Colors.blue.shade800),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blue.shade800, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefixIcon: Icon(Icons.shopping_bag_outlined, color: Colors.grey[600]),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Ce champ est obligatoire' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Prix',
                    floatingLabelStyle: TextStyle(color: Colors.blue.shade800),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blue.shade800, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefixIcon: Icon(Icons.attach_money_outlined, color: Colors.grey[600]),
                    prefixText: 'DH ',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Veuillez entrer un prix';
                    if (double.tryParse(value!) == null) return 'Nombre invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _stockController,
                  decoration: InputDecoration(
                    labelText: 'Quantité en stock',
                    floatingLabelStyle: TextStyle(color: Colors.blue.shade800),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blue.shade800, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefixIcon: Icon(Icons.inventory_2_outlined, color: Colors.grey[600]),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Veuillez entrer une quantité';
                    if (int.tryParse(value!) == null) return 'Nombre invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Catégorie avec nouveau style
                CategoryDropdown(
                  controller: _categoryController,
                  categories: categories,
                  onChanged: (Category? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                  labelText: 'Catégorie',
                  hintText: 'Sélectionnez une catégorie',
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  initialValue: productCategory,
                  isRequired: true,
                  dropdownColor: Colors.white,
                  style: TextStyle(color: Colors.blue.shade800),
                ),
                const SizedBox(height: 24),

                // Description avec nouveau style
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    floatingLabelStyle: TextStyle(color: Colors.blue.shade800),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blue.shade800, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefixIcon: Icon(Icons.description_outlined, color: Colors.grey[600]),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Nouveaux boutons avec meilleur style
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.grey.shade50,
                        ),
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Enregistrer',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}