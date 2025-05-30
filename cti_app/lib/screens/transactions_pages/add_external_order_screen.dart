// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cti_app/controller/product_controller.dart';
import 'package:cti_app/controller/supplier_controller.dart';
import 'package:cti_app/services/external_order_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/factures.dart';
import '/models/supplier.dart';
import '/services/activity_service.dart';
import '../../models/external_order.dart';
import 'add_extern_article_screen.dart';
import '../../models/product.dart';


class AddExternalOrderScreen extends StatefulWidget {
  final Function(ExternalOrder) onOrderAdded;

  const AddExternalOrderScreen({super.key, required this.onOrderAdded});

  @override
  AddExternalOrderScreenState createState() => AddExternalOrderScreenState();
}

class AddExternalOrderScreenState extends State<AddExternalOrderScreen> {
  // Liste de produits disponibles (remplacez par vos données réelles)
  List<Product> _availableProducts = [];
  List<Supplier> _supplier = [];


  @override
  void initState() {
    super.initState();
    _loadOption();
  }

        // Méthode pour rafraîchir les produits
    Future<void> _loadOption() async {
      final updatedProducts = await ProductController.fetchProducts();
      final updatedSuppliers = await SupplierController.getSuppliers();
      setState(() {
        _availableProducts = updatedProducts;
        _supplier = updatedSuppliers;
      });
    }


  final _formKey = GlobalKey<FormState>();
  final TextEditingController _supplierNameController = TextEditingController();
   int? _supplierId; // ID du fournisseur sélectionné
  OrderStatus _status = OrderStatus.pending;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  final TextEditingController _totalPriceController = TextEditingController();
  final TextEditingController _paidPriceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _remainingPriceController = TextEditingController();

  final List<OrderItem> _items = [];


  double returnTotalPrice() {
    return _items.fold(0.0, (sum, item) => sum + (item.unitPrice * item.quantity));
  }

  double returnPaidPrice() {
    if (_status == OrderStatus.completed) {
      return returnTotalPrice();
    } else {
      return double.tryParse(_paidPriceController.text) ?? 0.0;
    }
  }

  double returnRemainingPrice() {
    return returnTotalPrice() - returnPaidPrice();
  }

 void _submitForm() async {
  double totalPrice = returnTotalPrice();
  double paidPrice = returnPaidPrice();
  double remainingPrice = returnRemainingPrice();

  try {

    if (_formKey.currentState!.validate() && _items.isNotEmpty) {
    
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      final newOrder = ExternalOrder(
        orderNum: 'EXT-${DateTime.now().millisecondsSinceEpoch}',
        supplierId: _supplierId,
        supplierName: _supplierNameController.text,
        date: DateTime.now(),
        paymentMethod: _paymentMethod,
        totalPrice: totalPrice,
        paidPrice: paidPrice,
        remainingPrice: remainingPrice,
        description: _descriptionController.text,
        status: _status,
        items: _items,
      );

        final orderService = Provider.of<ExternalOrderService>(context, listen: false);
        final createdOrder = await orderService.addExternalOrder(newOrder);

      // Vérification de l'état de la commande
      if (_status == OrderStatus.completed) {
        // Mise à jour du stock pour chaque produit
        for (var item in _items) {
          final productIndex = _availableProducts.indexWhere(
              (product) => product.code == item.productRef);
          
          if (productIndex != -1) {
            final product = _availableProducts[productIndex];
            final newStock = product.stock + item.quantity;
            
            try {
              // Mise à jour en local
              setState(() {
                _availableProducts[productIndex] = product.copyWith(
                  stock: newStock,
                  available: newStock > 0,
                );
              });

              // Mise à jour sur le serveur
              await ProductController.updateProductStock(
                productId: product.id,
                newStock: newStock,
              );

              debugPrint('Stock mis à jour pour ${product.name}');
            } catch (e) {
              debugPrint('Erreur lors de la mise à jour du stock pour ${product.name}: $e');
              // Annuler la modification locale si l'API échoue
              setState(() {
                _availableProducts[productIndex] = product;
              });
              // Vous pourriez choisir de relancer l'exception ici si nécessaire
            }
          }
        }

        // Ajouter la facture si le statut est "Terminée"
        FactureFournisseur.addFactureForOrder(createdOrder);
      }
      
      widget.onOrderAdded(createdOrder);
      Provider.of<ActivityService>(context, listen: false).addActivity(
        "Ajout d’une nouvelle commande externe pour : ${newOrder.supplierName}",
        'shopping_cart',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins un article'),
          backgroundColor: Colors.red,
        ),
      );
    }
    Navigator.of(context).pop();
  } catch (e) {
    Navigator.pop(context);
    print(e);
  }
}

  Widget _buildFournisseurAutocomplete() {
    return Autocomplete<Supplier>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Supplier>.empty();
        }
        return _supplier.where((supplier) => 
          supplier.nameRespo.toLowerCase().contains(textEditingValue.text.toLowerCase())
        );
      },
      displayStringForOption: (Supplier option) => option.nameRespo,
      fieldViewBuilder: (BuildContext context, 
      TextEditingController textEditingController,
      FocusNode focusNode, 
      VoidCallback onFieldSubmitted) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Nom du Fournisseur*',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            suffixIcon: Icon(Icons.arrow_drop_down),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez ajouter un client';
            }
            return null;
          },
        );
      },
      onSelected: (Supplier selection) {
        setState(() {
          _supplierNameController.text = selection.nameRespo;
          _supplierId = selection.id;
        });
      },
      optionsViewBuilder: (BuildContext context,
      AutocompleteOnSelected<Supplier> onSelected,
      Iterable<Supplier> options) {
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
                  final Supplier option = options.elementAt(index);
                  return ListTile(
                    title: Text(option.nameRespo),
                    subtitle: Text(option.email),
                    onTap: () {
                      onSelected(option);
                    },
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
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Nouvelle Commande Fournisseur',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildFournisseurAutocomplete(),
              const SizedBox(height: 16),

              // Sélecteur de statut
              DropdownButtonFormField<OrderStatus>(
                value: _status,
                items: OrderStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_getStatusText(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _status = value;
                    });
                  }
                    setState(() {
                    _paidPriceController.text = returnPaidPrice().toStringAsFixed(2);
                    });
                  _remainingPriceController.text = returnRemainingPrice().toStringAsFixed(2);
                },
                decoration: InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sélecteur de méthode de paiement
              DropdownButtonFormField<PaymentMethod>(
                value: _paymentMethod,
                items: PaymentMethod.values.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _paymentMethod = value;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Moyen de Paiement*',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Champ pour le prix total
              TextFormField(
                enabled: false,
                controller: _totalPriceController,
                decoration: InputDecoration(
                  labelText: 'Prix Total',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Prix total requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Champ pour le prix payé
              TextFormField(
                controller: _paidPriceController,
                decoration: InputDecoration(
                  labelText: 'Prix Payé',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prix payé';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      returnPaidPrice();
                      _remainingPriceController.text = returnRemainingPrice().toStringAsFixed(2);
                    });
                  } else {
                    setState(() {
                      _remainingPriceController.text = returnTotalPrice().toStringAsFixed(2);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Champ pour le prix restant
              TextFormField(
                controller: _remainingPriceController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Prix Restant',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Champ pour la description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Liste des articles
              const Text('Articles:', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._items.map((item) => ListTile(
                    title: Text(item.productName),
                    subtitle: Text('${item.quantity * item.unitPrice} DH (${item.quantity})'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _items.remove(item);
                          _totalPriceController.text = returnTotalPrice().toStringAsFixed(3);
                          _paidPriceController.text = returnRemainingPrice().toStringAsFixed(3);
                          _remainingPriceController.text = returnRemainingPrice().toStringAsFixed(3);
                        });
                      },
                    ),
                  )),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 17, 109, 207),
                ),
                onPressed: () => _showAddArticleDialog(),
                child: const Text('Ajouter un Article', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Annuler', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF004A99),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Enregistrer', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddArticleDialog() async {
    await showDialog<List<OrderItem>>(
      context: context,
      builder: (context) => Dialog(
        child: AddExternalArticleDialog(
          availableProducts: _availableProducts,
          onArticlesAdded: (items) {
            setState(() {
              _items.addAll(items);
              _totalPriceController.text = returnTotalPrice().toStringAsFixed(2);
              _paidPriceController.text = returnPaidPrice().toStringAsFixed(2);
              _remainingPriceController.text = returnRemainingPrice().toStringAsFixed(2);
            });
            Navigator.of(context).pop(items);
          },
        ),
      ),
      useRootNavigator: false, // Important
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.processing:
        return 'En traitement';
      case OrderStatus.toPay:
        return 'À payer';
      case OrderStatus.completed:
        return 'Terminée';
      case OrderStatus.cancelled:
        return 'Annulée';
    }
  }
}