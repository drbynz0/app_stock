// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cti_app/controller/supplier_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/controller/product_controller.dart';
import '/services/activity_service.dart';
import '/models/supplier.dart';
import '/models/product.dart';

class EditSupplierScreen extends StatefulWidget {
  final Supplier supplier;
  final Function(Supplier) onEditSupplier;

  const EditSupplierScreen({
    super.key,
    required this.supplier,
    required this.onEditSupplier,
  });

  @override
  State<EditSupplierScreen> createState() => _EditSupplierScreenState();
}

class _EditSupplierScreenState extends State<EditSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _iceController;
  late final TextEditingController _nameRespoController;
  late final TextEditingController _nameEntController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _activityController;

  List<Product> products = [];


  late List<Product> selectedActivities;
  String productId = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _iceController = TextEditingController(text: widget.supplier.ice);
    _nameRespoController = TextEditingController(text: widget.supplier.nameRespo);
    _nameEntController = TextEditingController(text: widget.supplier.nameEnt);
    _emailController = TextEditingController(text: widget.supplier.email);
    _phoneController = TextEditingController(text: widget.supplier.phone);
    _addressController = TextEditingController(text: widget.supplier.address);
    _activityController = TextEditingController();
    selectedActivities = List.from(widget.supplier.products);
  }

    Future<void> _loadProducts() async {
    final fetchedProducts = await ProductController.fetchProducts();
    setState(() {
      products = fetchedProducts;
    });
  }

  void _submitForm() async {

    try {
      if (_formKey.currentState!.validate()) {

        // Afficher un indicateur de chargement
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );     
        final updateSupplier = Supplier(
          ice: _iceController.text,
          nameRespo: _nameRespoController.text,
          nameEnt: _nameEntController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          address: _addressController.text,
          products: selectedActivities,
        );

        final updatedSupplier = await SupplierController.updateSupplier(widget.supplier.id, updateSupplier);

        widget.onEditSupplier(updatedSupplier);
        Provider.of<ActivityService>(context, listen: false).addActivity(
          "Ajout d'un nouveau fournisseur : ${updatedSupplier.nameRespo}",
          'shopping_bag',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      print(e);
    }
  }

  Widget _buildActivityAutocomplete() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<Product>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Product>.empty();
            }
            return products.where((product) =>
                product.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
          },
          displayStringForOption: (Product option) => option.name,
          fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
              FocusNode focusNode, VoidCallback onFieldSubmitted) {
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Activité',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.shopping_cart),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                      setState(() {
                        textEditingController.clear();
                      });
                    }
                ),
              ),
            );
          },
          onSelected: (Product selection) {
            setState(() {
              if (!selectedActivities.contains(selection)) {
                selectedActivities.add(selection);
                _activityController.clear();
              }
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
        ),
        const SizedBox(height: 8),
        if (selectedActivities.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedActivities.map((activity) {
              return Chip(
                label: Text(activity.name),
                onDeleted: () {
                  setState(() {
                    selectedActivities.remove(activity);
                  });
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Modifier le Fournisseur',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _iceController,
                decoration: const InputDecoration(
                  labelText: 'ICE',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un ICE';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameRespoController,
                decoration: const InputDecoration(
                  labelText: 'Responsable',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameEntController,
                decoration: const InputDecoration(
                  labelText: 'Entreprise',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom d\'entreprise';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),

              _buildActivityAutocomplete(),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004A99),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Mettre à jour', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _iceController.dispose();
    _nameRespoController.dispose();
    _nameEntController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _activityController.dispose();
    super.dispose();
  }
}