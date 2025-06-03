// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:cti_app/controller/discount_controller.dart';
import 'package:cti_app/models/discounts.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/controller/product_controller.dart';
import '../../models/product.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../discounts_pages/details_discount_screen.dart';




class DetailsProductScreen extends StatefulWidget {
  final Product product;

  const DetailsProductScreen({super.key, required this.product});

  @override
  DetailsProductScreenState createState() => DetailsProductScreenState();
}

class DetailsProductScreenState extends State<DetailsProductScreen> {
  late Product product;
  late Discount discount;
  int _currentImageIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    product = widget.product;
    _refreshOption();
  }

  Future<void> _refreshOption() async {
    final promo = await DiscountController.getByProductId(product.id);
    setState(() {
      discount = promo;
    });
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(product.name, style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Galerie d'images
            _buildImageCarousel(),
            const SizedBox(height: 24),

            // Section Informations de base
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('Informations'),
                if(product.onPromo == true)
                GestureDetector(
                  onTap: () {
                    try {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsDiscountScreen(
                            discount: discount,
                            product: product,
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'En promotion',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5,)
              ]
            ),
            _buildInfoCard(
              children: [
                _buildInfoRow('Code', product.code),
                _buildInfoRow('Catégorie', product.category.name),
                _buildInfoRow('Etat', product.available == true ? 'Publié' : 'Non publié'),
                _buildInfoRow('Créé le', _formatDate(product.createdAt!)),
                _buildInfoRow('Modifié le', _formatDate(product.updatedAt!)),
              ],
            ),
            const SizedBox(height: 24),

            // Section Stock et Prix
            _buildSectionHeader('Stock & Prix'),
            _buildStockPriceCard(),
            const SizedBox(height: 24),

            // Section Description
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Description'),
                  _buildDescriptionCard(),
                  const SizedBox(height: 24),
                ],
              ),

            // Boutons d'action
            Row(
              children: [
 
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.public, color: Color(0xFF003366)),
                    label: const Text('Publier', style: TextStyle(color: Color(0xFF003366))),
                    onPressed: () =>
                    _publishProduct(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                SizedBox(width: 20),
               Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.inventory, color: Colors.white),
                    label: const Text('Gérer Stock', style: TextStyle(color: Colors.white)),
                    onPressed: () => _manageStock(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003366),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildImageCarousel() {
    return Column(
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: 300,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
          items: product.images.map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported, color: Colors.grey);
                    },
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: product.images.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _carouselController.animateToPage(entry.key),
              child: Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: entry.key == _currentImageIndex 
                      ? Colors.blue.shade800 
                      : Colors.grey.withOpacity(0.4),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: theme.titleColor,
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStockPriceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStockPriceItem(
              icon: Icons.inventory,
              label: 'Stock',
              value: product.stock.toString(),
              color: product.stock > 0 ? Colors.green : Colors.red,
            ),
            _buildStockPriceItem(
              icon: Icons.attach_money,
              label: 'Prix unitaire',
              value: '${product.price.toStringAsFixed(2)} DH',
              color: Colors.blue,
              decoration: TextDecoration.lineThrough
            ),
            _buildStockPriceItem(
              icon: Icons.calculate,
              label: 'Valeur stock',
              value: '${(product.stock * product.price).toStringAsFixed(2)} DH',
              color: Colors.purple,
              decoration: TextDecoration.lineThrough
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockPriceItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    TextDecoration? decoration,
  }) {
    return Column(
      children: [
        Icon(icon, size: 30, color: color),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
            decoration: product.onPromo == true ? decoration : null,
          ),
        ),
        if (product.onPromo == true && decoration != null && label == 'Prix unitaire')
        Text(
          '${product.promoPrice!.toStringAsFixed(2)} DH',
          style: TextStyle(fontSize: 10, color: Colors.red),
        ),
        if (product.onPromo == true && decoration != null && label == 'Valeur stock')
        Text(
          '${(product.stock * product.promoPrice!).toStringAsFixed(2)} DH',
          style: TextStyle(fontSize: 10, color: Colors.red),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      elevation: 2,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            product.description ?? 'Aucune description disponible',
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }

void _manageStock(BuildContext context) {
  final TextEditingController newStockController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Modifier le stock'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Stock actuel: ${product.stock}'),
            const SizedBox(height: 16),
            TextFormField(
              controller: newStockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nouvelle quantité',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une quantité';
                }
                if (int.tryParse(value) == null) {
                  return 'Veuillez entrer un nombre valide';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () async {
            if (formKey.currentState?.validate() ?? false) {
              final newStock = int.tryParse(newStockController.text);
              if (newStock != null) {
                // Afficher un indicateur de chargement
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );

                try {
                  // Appel API pour mettre à jour le stock dans le backend
                  await ProductController.updateProductStock(
                    productId: product.id,
                    newStock: newStock,
                  );

                  // Mise à jour de l'interface
                  setState(() {
                    product.stock = newStock;
                    product.updatedAt = DateTime.now();
                  });

                  // Fermer l'indicateur de chargement
                  Navigator.pop(context);

                  // Fermer la boîte de dialogue
                  Navigator.pop(context);

                  // Afficher un message de confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Stock mis à jour : $newStock'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } catch (e) {
                  // Fermer l'indicateur de chargement
                  Navigator.pop(context);

                  // Afficher un message d'erreur
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la mise à jour: ${e.toString()}'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            }
          },
          child: const Text('Valider'),
        ),
      ],
    ),
  );
}

void _publishProduct(BuildContext context) {
  bool isAvailable = product.available;
  final theme = Provider.of<ThemeProvider>(context, listen: false);

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: theme.dialogColor,
            title: const Text('Publication du produit'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Souhaitez-vous publier ce produit ?'),
                const SizedBox(height: 10),
                SwitchListTile(
                  inactiveThumbColor: theme.iconColor,
                  activeColor: theme.textColor,
                  title: Text(isAvailable ? 'Publié' : 'Non publié'),
                  value: isAvailable,
                  onChanged: (bool value) async {

                    // Afficher un indicateur de chargement
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );
                    try {
                      await ProductController.updateAvailable(product.id, value);

                      setState(() {
                        isAvailable = value;
                        product.available = value;
                        product.updatedAt = DateTime.now();
                      });

                      Navigator.of(dialogContext).pop();
                      Navigator.of(dialogContext).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Produit ${value ? 'publié' : 'dépublié'} avec succès', ), backgroundColor: Colors.green, duration: const Duration(seconds: 3),),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Fermer'),
                onPressed: () { 
                  Navigator.of(dialogContext).pop();
                  },
              ),
            ],
          );
        },
      );
    },
  );
}
  
}