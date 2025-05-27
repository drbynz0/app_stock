import 'dart:async';
import 'package:flutter/material.dart';
import '/models/product.dart';
import '/models/external_order.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';




class AddExternalArticleDialog extends StatefulWidget {
  final List<Product> availableProducts;
  final Function(List<OrderItem>) onArticlesAdded;

  const AddExternalArticleDialog({
    super.key,
    required this.availableProducts,
    required this.onArticlesAdded,
  });

  @override
  AddExternalArticleDialogState createState() => AddExternalArticleDialogState();
}

class AddExternalArticleDialogState extends State<AddExternalArticleDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Map<String, int> _selectedProducts = {}; // productId -> quantity

  List<Product> get _filteredProducts {
    return widget.availableProducts.where((product) {
      final query = _searchQuery.toLowerCase();
      return product.name.toLowerCase().contains(query) ||
             product.code.toLowerCase().contains(query);
    }).toList();
  }

  void _updateQuantity(String productId, int quantity) {
    setState(() {
      if (quantity > 0) {
        _selectedProducts[productId] = quantity;
      } else {
        _selectedProducts.remove(productId);
      }
    });
  }

  void _submitSelection() {
    final selectedItems = _selectedProducts.entries.map((entry) {
      final product = widget.availableProducts.firstWhere((p) => p.code == entry.key);
      return OrderItem(
        productId: product.id,
        productRef: product.code,
        productName: product.name,
        productImage: product.images[0],
        quantity: entry.value.toInt(),
        unitPrice: product.price,
      );
    }).toList();

    widget.onArticlesAdded(selectedItems);
  }

  Future<String?> _scanBarcode() async {
    final cameraStatus = await Permission.camera.request();
    if (cameraStatus != PermissionStatus.granted) {
      return null;
    }

    final completer = Completer<String?>();
    
    await showDialog(
      // ignore: use_build_context_synchronously
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
    final totalPrice = _selectedProducts.entries.fold(0.0, (sum, entry) {
      final product = widget.availableProducts.firstWhere((p) => p.code == entry.key);
      return sum + (product.price * entry.value);
    });

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ajouter des articles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Barre de recherche
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un article...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.barcode_reader, color: Colors.blue),
                  onPressed: () async {
                    final scannedCode = await _scanBarcode();
                    if (scannedCode != null) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Code scanné: $scannedCode'), 
                          duration: const Duration(seconds: 2), 
                          backgroundColor: Colors.green,
                        ),
                      );
                      
                      try {
                        final product = widget.availableProducts.firstWhere(
                          (p) => p.code == scannedCode,
                        );
                        
                        setState(() {
                          _searchQuery = product.name;
                          _searchController.text = product.name;
                          _selectedProducts[product.code] = (_selectedProducts[product.code] ?? 0) + 1;
                        });
                        
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final index = _filteredProducts.indexWhere((p) => p.code == product.code);
                          if (index != -1) {
                            Scrollable.ensureVisible(
                              context,
                              alignment: 0.5,
                              duration: const Duration(milliseconds: 300),
                            );
                          }
                        });
                        
                      } catch (e) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Aucun produit trouvé pour le code $scannedCode'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Liste des produits
            Expanded(
              child: ListView.builder(
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
                  final quantity = _selectedProducts[product.code] ?? 0;

                  return Card(
                    color: quantity > 0 ? const Color.fromARGB(255, 114, 185, 243) : const Color.fromARGB(255, 227, 237, 242),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Text('Prix: ${product.price.toStringAsFixed(2)} DH'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: Colors.red),
                            onPressed: () => _updateQuantity(product.code, quantity - 1),
                          ),
                          Text('$quantity'),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.green),
                            onPressed: () => _updateQuantity(product.code, quantity + 1),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Résumé de la commande (déplacé ici)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectedProducts.length} article(s)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${totalPrice.toStringAsFixed(2)} DH',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Boutons Annuler et Ajouter
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedProducts.isNotEmpty ? const Color(0xFF004A99) : Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: _selectedProducts.isNotEmpty ? _submitSelection : null,
                  child: const Text('Ajouter', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}