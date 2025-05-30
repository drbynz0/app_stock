// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cti_app/controller/customer_controller.dart';
import 'package:cti_app/controller/delivery_notes_controller.dart';
import 'package:cti_app/controller/product_controller.dart';
import 'package:cti_app/services/alert_service.dart';
import 'package:cti_app/services/app_data_service.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import '/models/delivery_note.dart';
import 'package:provider/provider.dart';
import '/models/factures.dart';
import '/services/activity_service.dart';
import '../../models/internal_order.dart';
import '../../models/product.dart';
import '../../models/client.dart';
import 'add_intern_article_screen.dart';

class AddInternalOrderScreen extends StatefulWidget {
  final Function(InternalOrder) onOrderAdded;

  const AddInternalOrderScreen({super.key, required this.onOrderAdded});

  @override
  AddInternalOrderScreenState createState() => AddInternalOrderScreenState();
}

class AddInternalOrderScreenState extends State<AddInternalOrderScreen> {

  List<Product> _availableProducts = [];
  List<Client> _clients = [];


  @override
  void initState() {
    super.initState();
    _loadOption();
    }

      // Méthode pour rafraîchir les produits
    Future<void> _loadOption() async {
      final updatedProducts = await ProductController.fetchProducts();
      final updatedClients = await CustomerController.getCustomers();
      setState(() {
        _availableProducts = updatedProducts;
        _clients = updatedClients;
      });
    }

  
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clientNameController = TextEditingController();
  TypeOrder _type = TypeOrder.inStore;
  OrderStatus _status = OrderStatus.pending;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  final TextEditingController _totalPriceController = TextEditingController();
  final TextEditingController _paidPriceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _remainingPriceController = TextEditingController();
  int? _clientId;

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

  void _submitForm()async {
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
        final newOrder = InternalOrder(
          orderNum: 'CMD-${DateTime.now().millisecondsSinceEpoch}',
          clientId: _clientId,
          clientName: _clientNameController.text,
          typeOrder: _type,
          date: DateTime.now(),
          paymentMethod: _paymentMethod,
          totalPrice: totalPrice,
          paidPrice: paidPrice,
          remainingPrice: remainingPrice,
          description: _descriptionController.text,
          status: _status,
          items: _items,
          payments: [],
        );


        // Enregistrement de la commande
        final appData = Provider.of<AppData>(context, listen: false);
        final createdOrder = await appData.addInternalOrder(newOrder);
        // Créer le nouveau paiement
        final newPayment = Payments(
          order: createdOrder,
          totalPaid: paidPrice,
          paymentMethod: _paymentMethod,
          note: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
          paidAt: DateTime.now().toIso8601String(),
        );
        // Ajouter le paiement à la commande
        appData.addPayment(createdOrder.id!, newPayment);
        createdOrder.payments?.add(newPayment);

      // Vérification de l'état de la commande
      if (_status == OrderStatus.completed) {
        // Mise à jour du stock pour chaque produit
        for (var item in _items) {
          final productIndex = _availableProducts.indexWhere(
              (product) => product.code == item.productRef);
          
          if (productIndex != -1) {
            final product = _availableProducts[productIndex];
            final newStock = product.stock - item.quantity;
            
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
        FactureClient.addFactureForOrder(createdOrder);
      }

        // Créer un bon de livraison si la commande est en ligne
        if (_type == TypeOrder.online) {
          _createDeliveryNote(createdOrder);
        }

        widget.onOrderAdded(newOrder);
        Provider.of<ActivityService>(context, listen: false).addActivity(
          "Ajout d’une nouvelle commande interne pour : ${newOrder.clientName}",
          'person_add',
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez ajouter au moins un article'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stack) {
    if (mounted) {
      Navigator.pop(context);
      debugPrint('Erreur: $e');
      debugPrint('Stack trace: $stack');
      AlertService.showAlert(
        context: context,
        title: 'Erreur',
        message: 'Une erreur est survenue lors de la création de la commande',
      );
    }  
    }
  }

  void _createDeliveryNote(InternalOrder order) async {
    // Convertir les OrderItem en DeliveryItem
    final deliveryItems = order.items.map((item) => DeliveryItem(
      productCode: item.productRef,
      description: item.productName,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
    )).toList();

    // Créer le bon de livraison
    final deliveryNote = DeliveryNote(
      noteNumber: 'BL-${DateTime.now().millisecondsSinceEpoch}',
      date: order.date,
      clientId: order.clientId,
      clientName: order.clientName,
      clientAddress: _clients.firstWhere((c) => c.id == order.clientId).address,
      items: deliveryItems,
      preparedBy: 'Préparateur', // Vous pouvez remplacer par le nom de l'utilisateur connecté
      orderNum: order.orderNum,
    );

    // Ajouter le bon de livraison à votre liste
    await DeliveryNoteController.createDeliveryNote(deliveryNote);
  }

  Widget _buildClientAutocomplete() {
    return Autocomplete<Client>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Client>.empty();
        }
        return _clients.where((client) => 
          client.name.toLowerCase().contains(textEditingValue.text.toLowerCase())
        );
      },
      displayStringForOption: (Client option) => option.name,
      fieldViewBuilder: (BuildContext context, 
      TextEditingController textEditingController, 
      FocusNode focusNode, 
      VoidCallback onFieldSubmitted) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Nom du Client*',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),            
            suffixIcon: Icon(Icons.arrow_drop_down),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez sélectionner ou saisir un client';
            }
            return null;
          },
        );
      },
      onSelected: (Client selection) {
        setState(() {
          _clientNameController.text = selection.name;
          _clientId = selection.id; // Met à jour l'ID du client sélectionné
        });
      },
      optionsViewBuilder: (BuildContext context,
      AutocompleteOnSelected<Client> onSelected,
      Iterable<Client> options) {
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
                  final Client option = options.elementAt(index);
                  return ListTile(
                    title: Text(option.name),
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
    final theme = Provider.of<ThemeProvider>(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: theme.dialogColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nouvelle Commande Client',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.iconColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Champ pour le nom du client
              _buildClientAutocomplete(),
              const SizedBox(height: 16),

              const SizedBox(height: 16),

              DropdownButtonFormField<TypeOrder>(
                value: _type,
                items: TypeOrder.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getTypeText(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _type = value;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Type de commande',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),                
                ),
              ),
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
                    _remainingPriceController.text = returnRemainingPrice().toStringAsFixed(2);
                    });
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
                      returnRemainingPrice();
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
                          _totalPriceController.text = returnTotalPrice().toStringAsFixed(2);
                          _paidPriceController.text = '0.00';
                          _remainingPriceController.text = returnRemainingPrice().toStringAsFixed(2);
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
                        backgroundColor: theme.backgroundColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text('Annuler', style: TextStyle(fontSize: 16)),
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
    ),
    );
  }

  void _showAddArticleDialog() async {
    await showDialog<List<OrderItem>>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: AddInternArticleDialog(
          availableProducts: _availableProducts,
          onArticlesAdded: (items) {
            setState(() {
              _items.addAll(items);
              _totalPriceController.text = returnTotalPrice().toStringAsFixed(2);
              _remainingPriceController.text = returnRemainingPrice().toStringAsFixed(2);
              if(_status == OrderStatus.completed) {
                _paidPriceController.text = returnTotalPrice().toStringAsFixed(2);
              } else {
                _paidPriceController.text = '0.00';
              }
            });
            Navigator.of(context).pop(items);
          },
        ),
      ),
      useRootNavigator: false,
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

  String _getTypeText(TypeOrder type) {
    switch (type) {
      case TypeOrder.online:
        return 'En ligne';
      case TypeOrder.inStore:
        return 'En magasin';
    }
  }
}