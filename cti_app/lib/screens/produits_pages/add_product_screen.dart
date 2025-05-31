// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cti_app/services/app_data_service.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '/controller/category_controller.dart';
import '/models/category.dart';
import '/models/product.dart';
import '/services/activity_service.dart';
import '/widgets/build_category.dart';

class AddProductScreen extends StatefulWidget {
  final Function(Product) onProductAdded;

  const AddProductScreen({super.key, required this.onProductAdded});

  @override
  AddProductScreenState createState() => AddProductScreenState();
}

class AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _variantController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _categoryController = TextEditingController();
  final _marqueController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<File?> _imageFiles = List.filled(4, null);

  Category _selectedCategory = Category.empty();
  bool _isLoading = false;
  Category? _preSelectedCategory;
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final loadedCategories = await CategoryController.fetchCategories();
      if (mounted) {
        setState(() {
          categories = loadedCategories;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur chargement catégories: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage(int index) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      setState(() {
        _imageFiles[index] = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final selectedImages = _imageFiles.whereType<File>().toList();
      if (selectedImages.isEmpty) {
        throw Exception('Veuillez sélectionner au moins une image');
      }

      final newProduct = Product(
        id: null,
        name: _nameController.text.trim(),
        marque: _marqueController.text.trim(),
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        variants: int.parse(_variantController.text),
        category: _selectedCategory,
        code: _codeController.text.trim(),
        description: _descriptionController.text.trim(),
        available: int.parse(_stockController.text) > 0,
        images: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        onPromo: false,
        promoPrice: null,
      );

      final appData = Provider.of<AppData>(context, listen: false);
      final createdProduct = await appData.addProduct(newProduct, selectedImages);

      if (mounted) {
        Provider.of<ActivityService>(context, listen: false)
          .addActivity("Ajout produit: ${createdProduct.name}", 'add');
        
        widget.onProductAdded(createdProduct);
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produit "${createdProduct.name}" ajouté avec succès'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String?> _scanBarcode() async {
    final cameraStatus = await Permission.camera.request();
    if (cameraStatus != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission caméra refusée')),
        );
      }
      return null;
    }

    final completer = Completer<String?>();
    
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              MobileScanner(
                controller: MobileScannerController(
                  detectionSpeed: DetectionSpeed.normal,
                  facing: CameraFacing.back,
                  torchEnabled: false,
                ),
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty && !completer.isCompleted) {
                    Navigator.pop(context);
                    completer.complete(barcodes.first.rawValue);
                  }
                },
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.pop(context);
                    if (!completer.isCompleted) {
                      completer.complete(null);
                    }
                  },
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Scannez un code-barres',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return completer.future;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _variantController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    _marqueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // En-tête
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.add_shopping_cart, size: 32, color: theme.iconColor),
                          const SizedBox(width: 10),
                          Text(
                            'Nouveau Produit',
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
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  const SizedBox(height: 16),

                  // Section images
                  Text(
                    'Images du produit* (max 4)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.titleColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _pickImage(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.searchBar,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.borderColor,
                              width: 2,
                            ),
                          ),
                          child: _imageFiles[index] == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 30),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Image ${index + 1}',
                                    ),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(_imageFiles[index]!, fit: BoxFit.cover),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Champ code avec scan
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _codeController,
                          decoration: InputDecoration(
                            labelText: 'Code produit*',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: theme.borderColor),
                            ),
                            prefixIcon: Icon(Icons.code),
                            filled: true,
                            fillColor: theme.textFieldColor,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Code obligatoire';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        decoration: BoxDecoration(
                          color: theme.backgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            final scannedBarcode = await _scanBarcode();
                            if (scannedBarcode != null && mounted) {
                              final player = AudioPlayer();
                              await player.play(AssetSource('sounds/beep.mp3'));
                              setState(() {
                                _codeController.text = scannedBarcode;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Code scanné: $scannedBarcode'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.barcode_reader),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Champ nom
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nom du produit*',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
                      ),
                      prefixIcon: Icon(Icons.shopping_bag, color: Colors.blue.shade800),
                      filled: true,
                      fillColor: theme.textFieldColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nom obligatoire';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Champ variante
                  TextFormField(
                    controller: _variantController,
                    decoration: InputDecoration(
                      labelText: 'Variante*',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
                      ),
                      prefixIcon: Icon(Icons.inventory, color: Colors.blue.shade800),
                      filled: true,
                      fillColor: theme.textFieldColor,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Variante obligatoire';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Nombre entier requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Champ marque
                  TextFormField(
                    controller: _marqueController,
                    decoration: InputDecoration(
                      labelText: 'Marque*',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
                      ),
                      prefixIcon: Icon(Icons.branding_watermark, color: Colors.blue.shade800),
                      filled: true,
                      fillColor: theme.textFieldColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Marque obligatoire';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Champ prix
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Prix* (DH)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
                      ),
                      prefixIcon: Icon(Icons.attach_money, color: Colors.blue.shade800),
                      filled: true,
                      fillColor: theme.textFieldColor,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Prix obligatoire';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Nombre valide requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Champ stock
                  TextFormField(
                    controller: _stockController,
                    decoration: InputDecoration(
                      labelText: 'Stock*',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
                      ),
                      prefixIcon: Icon(Icons.inventory_2, color: Colors.blue.shade800),
                      filled: true,
                      fillColor: theme.textFieldColor,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Stock obligatoire';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Nombre entier requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Champ catégorie
                  CategoryDropdown(
                    controller: _categoryController,
                    categories: categories,
                    onChanged: (Category? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      }
                    },
                    labelText: 'Catégorie*',
                    hintText: 'Sélectionnez une catégorie',
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    initialValue: _preSelectedCategory,
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  // Champ description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
                      ),
                      prefixIcon: Icon(Icons.description, color: Colors.blue.shade800),
                      filled: true,
                      fillColor: theme.textFieldColor,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Bouton d'envoi
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'AJOUTER LE PRODUIT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Overlay de chargement
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}