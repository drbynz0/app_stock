// ignore_for_file: use_build_context_synchronously

import 'package:cti_app/controller/customer_controller.dart';
import 'package:cti_app/controller/internal_orders_controller.dart';
import 'package:cti_app/controller/product_controller.dart';
import 'package:cti_app/services/alert_service.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/client.dart';
import '/models/delivery_note.dart';
import '/services/activity_service.dart';
import '../../models/internal_order.dart';
import '../../models/product.dart';
import 'add_intern_article_screen.dart';
import '/models/factures.dart'; 

class EditInternalOrderScreen extends StatefulWidget {
  final InternalOrder order;
  final Function(InternalOrder) onOrderUpdated;

  const EditInternalOrderScreen({
    super.key, 
    required this.order,  
    required this.onOrderUpdated,
  }); 
  @override
  EditInternalOrderScreenState createState() => EditInternalOrderScreenState();
}
          
class EditInternalOrderScreenState extends State<EditInternalOrderScreen> {

  List<Product> _availableProducts = [];


  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _clientNameController;
  late TypeOrder _type;
  late OrderStatus _status;
  late PaymentMethod _paymentMethod;
  late final TextEditingController _totalPriceController;
  late final TextEditingController _paidPriceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _remainingPriceController;
  late DateTime _selectedDate;
  late List<OrderItem> _items;
  int? _clientId;
  List<Client> _clients = []; // Récupère la liste des clients



  @override
  void initState() {
    super.initState();
    _loadOption();
    _clientNameController = TextEditingController(text: widget.order.clientName);
    _type = widget.order.typeOrder;
    _status = widget.order.status;
    _paymentMethod = widget.order.paymentMethod;
    _totalPriceController = TextEditingController(text: widget.order.totalPrice.toStringAsFixed(2));
    _paidPriceController = TextEditingController(text: widget.order.paidPrice.toStringAsFixed(2));
    _descriptionController = TextEditingController(text: widget.order.description);
    _remainingPriceController = TextEditingController(text: widget.order.remainingPrice.toStringAsFixed(2));
    _selectedDate = widget.order.date;
    _items = List.from(widget.order.items);
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

  @override
  void dispose() {
    _clientNameController.dispose();
    _paidPriceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

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
        // Afficher un indicateur de chargement
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
      
      if (_formKey.currentState!.validate() && _items.isNotEmpty) {
        final updateOrder = InternalOrder(
          id: widget.order.id,
          orderNum: widget.order.orderNum,
          clientId: _clientId,
          clientName: _clientNameController.text,
          typeOrder: _type,
          date: _selectedDate,
          paymentMethod: _paymentMethod,
          totalPrice: totalPrice,
          paidPrice: paidPrice,
          remainingPrice: remainingPrice,
          description: _descriptionController.text,
          status: _status,
          items: _items,
          updated: DateTime.now(),
        );

        final updatedOrder = await InternalOrdersController.updateOrder(widget.order.id!, updateOrder);

        if (_type == TypeOrder.online) {
          _updateDeliveryNote(updatedOrder);
        }
        widget.onOrderUpdated(updatedOrder);

        FactureClient.updateFactureForOrder(updatedOrder);

        Provider.of<ActivityService>(context, listen: false).addActivity(
        "Modification d’une commande interne pour : ${updatedOrder.clientName}",
        'shopping_cart',
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
        debugPrint('$stack');
        AlertService.showAlert(
          context: context,
          title: 'Erreur',
          message: 'Une erreur est survenue lors de la modification de la commande',
        );
      }     
    }
  }

    void _updateDeliveryNote(InternalOrder order) {
    final deliveryItems = order.items.map((item) => DeliveryItem(
      productCode: item.productRef,
      description: item.productName,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
    )).toList();

    Client client = Client.getClientById(order.clientId);
    final index = DeliveryNote.getDeliveryNotes().indexWhere((d) => d.orderNum == order.orderNum);

    if (index != -1) {
      DeliveryNote.getDeliveryNotes()[index] = DeliveryNote(
        noteNumber: 'BL-${DateTime.now().millisecondsSinceEpoch}',
        date: order.date,
        clientName: order.clientName,
        clientAddress: client.address,
        items: deliveryItems,
        preparedBy: 'Préparateur',
        orderNum: order.orderNum,
      );
    } else {
      DeliveryNote.addDeliveryNote(
        DeliveryNote(
          noteNumber: 'BL-${DateTime.now().millisecondsSinceEpoch}',
          date: order.date,
          clientName: order.clientName,
          clientAddress: client.address,
          items: deliveryItems,
          preparedBy: 'Préparateur',
          orderNum: order.orderNum,
        ),
      );
    }


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
        // Synchronise le texte initial si besoin
        if (textEditingController.text.isEmpty && _clientNameController.text.isNotEmpty) {
          textEditingController.text = _clientNameController.text;
          _clientId = widget.order.clientId;
        }
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Nom du Client*',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),            suffixIcon: Icon(Icons.arrow_drop_down),
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
          _clientId = selection.id;
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
        borderRadius: BorderRadius.circular(20),
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
                'Modifier Commande Client',
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

              // Sélecteur de date
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date de Commande',
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
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
                    _paidPriceController.text = returnPaidPrice().toStringAsFixed(3);
                    _remainingPriceController.text = returnRemainingPrice().toStringAsFixed(3);
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Statut',
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
                ),
              ),
              const SizedBox(height: 24),

              // Champ pour le prix total
              TextFormField(
                enabled: false,
                controller: _totalPriceController,
                decoration: InputDecoration(
                  labelText: 'Prix Total',
                ),
              ),
              const SizedBox(height: 16),

              // Champ pour le prix payé
              TextFormField(
                controller: _paidPriceController,
                decoration: InputDecoration(
                  labelText: 'Prix Payé',
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
                ),
              ),
              const SizedBox(height: 16),

              // Champ pour la description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
              ),
              const SizedBox(height: 16),

              // Liste des articles
              const Text('Articles:', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._items.map((item) => ListTile(
                    title: Text(item.productName),
                    subtitle: Text('${(item.quantity * item.unitPrice).toStringAsFixed(3)} DH (${item.quantity})'),
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

              // Boutons d'action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: theme.backgroundColor,
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