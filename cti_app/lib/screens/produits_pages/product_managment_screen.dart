// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:cti_app/controller/category_controller.dart';
import 'package:cti_app/controller/login_controller.dart';
import 'package:cti_app/controller/user_controller.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/controller/product_controller.dart';
import '/models/category.dart';
import '/services/activity_service.dart';
import 'add_product_screen.dart';
import '/models/product.dart';
import 'delete_product_screen.dart';
import 'edit_product_screen.dart';
import 'details_product_screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';



class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  ProductManagementScreenState createState() => ProductManagementScreenState();
}

class ProductManagementScreenState extends State<ProductManagementScreen> {
  List<Product> products = [];
  Category? _selectedCategory;
  String _searchQuery = '';
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  List<Category> categories = [];
  Map<String, dynamic>? myPrivileges = {};


  @override
  void initState() {
    super.initState();
    _refreshOption();
  }

  // Méthode pour rafraîchir les produits
  Future<void> _refreshOption() async {
    final availablePrivileges = await UserController.fetchUserPrivileges();
    final updatedProducts = await ProductController.fetchProducts();
    categories = await CategoryController.fetchCategories();
    setState(() {
      myPrivileges = availablePrivileges;
      products = updatedProducts;
    });
  }

  List<Product> get filteredProducts {
    return products.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null || 
      product.category.name.toString() == _selectedCategory!.name.toString();
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<Product> get paginatedProducts {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return filteredProducts.sublist(
      startIndex.clamp(0, filteredProducts.length),
      endIndex.clamp(0, filteredProducts.length),
    );
  }


    Future<String?> _scanBarcode() async {
    final cameraStatus = await Permission.camera.request();
    if (cameraStatus != PermissionStatus.granted) {
      return null;
    }

    final completer = Completer<String?>();
    
    await showDialog(
      context: context,
      builder: (context) => Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.black,
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
                  if (barcodes.isNotEmpty) {
                    Navigator.pop(context);
                    completer.complete(barcodes.first.rawValue);
                  }
                },
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                    completer.complete(null);
                  },
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
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    setState(() {
    });
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Barre de recherche
              Container(
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: theme.searchBar,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: theme.shadowColor,
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher des produits...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _currentPage = 1;
                    });
                  },
                ),
              ),
              // Ligne avec sélecteur 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  children: [
                    // Sélecteur de catégorie
                    Expanded(
                      flex: 3,
                      child: 
                        _buildCategoryDropdown(),
                    ),
                    // Bouton Exporter
                  ],
                ),
              ),
              
              // Liste des produits
              Expanded(
                child: ListView.builder(
                  itemCount: paginatedProducts.length,
                  itemBuilder: (context, index) {
                    final product = paginatedProducts[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsProductScreen(
                              product: product,
                            ),
                          ),
                        ).then((_) {
                          setState(() { 
                          });
                        }); 
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                              product.images[0],
                               // AppConstant.DEFAULT_IMAGE,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.image_not_supported, color: Colors.grey);
                                },
                              ),
                            ),
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                children: [
                                  Text(
                                    product.category.name,
                                    style: TextStyle(
                                      color: theme.secondaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(width: 5,),
                                  Text(product.available == true ? 'Publié' : 'Non publié', 
                                    style: TextStyle(
                                      color: product.available == true ? Colors.green : Colors.red,
                                    ),
                                  ),

                                ],
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                children: [
                                  Text(
                                    '${product.stock} en stock',
                                    style: TextStyle(
                                      color: product.stock <= 10 ? Colors.red : Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${product.price.toStringAsFixed(2)} MAD',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (myPrivileges!['edit_product'] ?? true)
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showEditDialog(index),
                              ),
                              if (myPrivileges!['delete_product'] ?? true)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed:  () => _showDeleteDialog(product),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 60),
              // Pagination
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filteredProducts.length} éléments',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Row(
                      children: [
                        Text(
                          'Page $_currentPage/${(filteredProducts.length / _itemsPerPage).ceil()}',
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _currentPage > 1
                              ? () => setState(() => _currentPage--)
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: _currentPage < (filteredProducts.length / _itemsPerPage).ceil()
                              ? () => setState(() => _currentPage++)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Bouton de scanne produit
          AuthController.isadmin == 'ADMIN' || (myPrivileges!['add_product'] ?? true)
              ? buildButtonScan(120) 
              : buildButtonScan(60),
            if ((AuthController.isadmin == 'ADMIN') || (myPrivileges!['add_product'] ?? true))
            Positioned(
              right: 15,
              bottom: 60,
              child: FloatingActionButton(
                onPressed: _showAddProductDialog,
                backgroundColor: theme.buttonColor,
                elevation: 4,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    
    return DropdownButtonFormField<Category>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Catégorie',
        border: OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text('Toutes les catégories')),
        ...categories.map((categorie) {
          return DropdownMenuItem(
            value: categorie,
            child: Text(categorie.name),
          );
        }),
      ],
      onChanged: (value) => setState(() {
        _selectedCategory = value;
        _currentPage = 1;
      }),
    );
  }



  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AddProductScreen(
        onProductAdded: (newProduct) async {
          // actualiser la liste des produits
            await _refreshOption();
          if (mounted) {

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${newProduct.name} ajouté avec succès'),
                duration: const Duration(seconds: 3),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context); // Fermer le dialogue après l'ajout
            
            // 3. Ajouter à l'historique d'activité
            Provider.of<ActivityService>(context, listen: false)
              .addActivity("Ajout produit: ${newProduct.name}", 'add');
          } else {
              showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Erreur'),
                  content: const Text('Erreur lors de l\'ajout du produit'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop(); // Ferme la boîte de dialogue
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }

  

  void _showDeleteDialog(Product produit) {
    try {
    showDialog(
      context: context,
      builder: (context) => DeleteProductScreen(
        product: produit,
        onDeleteConfirmed: () async {
            if (produit.id != null) {
              await ProductController.deleteProduct(produit.id!);             
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Erreur : ID du produit est null'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
            Provider.of<ActivityService>(context, listen: false).addActivity(
              "Suppression du produit : ${produit.name}",
              'shopping_bag',
            );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${produit.name} supprimé avec succès'), duration: const Duration(seconds: 3), backgroundColor: Colors.red,),
          );
        },
      ),
    );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Fermer l'indicateur en cas d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }      
    }
  }

  void _showEditDialog(int index) {
    final productIndex = products.indexOf(paginatedProducts[index]);
    showDialog(
      context: context,
      builder: (context) => EditProductScreen(
        product: products[productIndex],
        onProductUpdated: (updatedProduct) async {
          // 1. Rafraîchir la liste complète
          await _refreshOption();
          
          // 2. Afficher le feedback
          if (mounted) {
            Navigator.pop(context); // Fermer l'indicateur en cas d'erreur
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Produit "${updatedProduct.name}" mis à jour'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
            ),
            );
            
            Provider.of<ActivityService>(context, listen: false)
              .addActivity("Modification produit: ${updatedProduct.name}", 'edit');
          }
        },
      ),
    );
  }

  Widget buildButtonScan(double bottom) {
    return Positioned(
      right: 23,
      bottom: bottom,
      child: IconButton(
        onPressed: () async {
          final scannedBarcode = await _scanBarcode(); // Appel de la méthode _scanBarcode
          if (scannedBarcode != null) {
            try {
              // Recherche du produit correspondant
              final matchingProduct = products.firstWhere(
                (product) => product.code == scannedBarcode,
              );

              // Afficher un message de succès
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Produit trouvé : ${matchingProduct.name}'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );

              // Naviguer vers les détails du produit scanné
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsProductScreen(product: matchingProduct),
                ),
              );
            } catch (e) {
              // Afficher un message d'erreur si aucun produit n'est trouvé
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Aucun produit trouvé pour le code $scannedBarcode'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          } else {
            // Afficher un message si le scan est annulé
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Scan annulé'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        icon: const Icon(Icons.barcode_reader, color: Color.fromARGB(255, 18, 65, 85), size: 30),
      ),
    );
  }
}