// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cti_app/controller/external_orders_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/factures.dart';
import '/services/activity_service.dart';
import '../../models/external_order.dart';
import '../../models/product.dart';
import 'add_extern_article_screen.dart';
import '/services/app_data_service.dart';

class EditExternalOrderScreen extends StatefulWidget {
  final ExternalOrder order;
  final Function(ExternalOrder) onOrderUpdated;

  const EditExternalOrderScreen({
    super.key,
    required this.order,
    required this.onOrderUpdated,
  });

  @override
  EditExternalOrderScreenState createState() => EditExternalOrderScreenState();
}

class EditExternalOrderScreenState extends State<EditExternalOrderScreen> {

  List<Product> _availableProducts = [];

  
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _supplierNameController;
  late OrderStatus _status;
  late PaymentMethod _paymentMethod;
  late final TextEditingController _totalPriceController;
  late final TextEditingController _paidPriceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _remainingPriceController;
  late DateTime _selectedDate;
  late List<OrderItem> _items;

  @override
  void initState() {
    super.initState();
    _availableProducts = Provider.of<AppData>(context, listen: false).products;
    _supplierNameController = TextEditingController(text: widget.order.supplierName);
    _status = widget.order.status;
    _paymentMethod = widget.order.paymentMethod;
    _totalPriceController = TextEditingController(text: widget.order.totalPrice.toStringAsFixed(2));
    _paidPriceController = TextEditingController(text: widget.order.paidPrice.toStringAsFixed(2));
    _descriptionController = TextEditingController(text: widget.order.description);
    _remainingPriceController = TextEditingController(text: widget.order.remainingPrice.toStringAsFixed(2));
    _selectedDate = widget.order.date;
    _items = List.from(widget.order.items);
  }

  @override
  void dispose() {
    _supplierNameController.dispose();
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
    if (_formKey.currentState!.validate() && _items.isNotEmpty) {
        // Afficher un indicateur de chargement
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
      
      final updateOrder = ExternalOrder(
        id: widget.order.id,
        orderNum: widget.order.orderNum,
        supplierId: widget.order.supplierId,
        supplierName: _supplierNameController.text,
        date: _selectedDate,
        paymentMethod: _paymentMethod,
        totalPrice: totalPrice,
        paidPrice: paidPrice,
        remainingPrice: remainingPrice,
        description: _descriptionController.text,
        status: _status,
        items: _items,
      );

      final updatedOrder = await ExternalOrdersController.updateOrder(widget.order.id!, updateOrder);

      
      widget.onOrderUpdated(updatedOrder);

      FactureFournisseur.updateFactureForOrder(updatedOrder);

      Provider.of<ActivityService>(context, listen: false).addActivity(
        "Modification d’une commande externe pour : ${updatedOrder.supplierName}",
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
    
    } catch (e) {
      Navigator.pop(context);
      print(e);
    }
    
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
                'Modifier Commande Fournisseur',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Champ pour le nom du fournisseur
              TextFormField(
                controller: _supplierNameController,
                decoration: InputDecoration(
                  labelText: 'Nom du Fournisseur*',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sélecteur de date
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date de Commande',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                onChanged: (value) {
                  setState(() {
                    _remainingPriceController.text = returnRemainingPrice().toStringAsFixed(2);
                  });
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
                    subtitle: Text('${(item.quantity * item.unitPrice).toStringAsFixed(2)} DH (${item.quantity})'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _items.remove(item);
                          _totalPriceController.text = returnTotalPrice().toStringAsFixed(2);
                          _paidPriceController.text = returnPaidPrice().toStringAsFixed(2);
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
    final List<OrderItem>? selectedItems = await showDialog<List<OrderItem>>(
      context: context,
      builder: (context) => Dialog(
        child: AddExternalArticleDialog(
          availableProducts: _availableProducts,
          onArticlesAdded: (items) => Navigator.of(context).pop(items),
        ),
      ),
      useRootNavigator: false,
    );

    if (selectedItems != null && selectedItems.isNotEmpty) {
      setState(() {
        _items.addAll(selectedItems);
        _totalPriceController.text = returnTotalPrice().toStringAsFixed(2);
        _remainingPriceController.text = returnRemainingPrice().toStringAsFixed(2);
      });
    }
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