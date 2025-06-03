// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cti_app/controller/supplier_controller.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/controller/product_controller.dart';
import '/services/activity_service.dart';
import '/models/supplier.dart';
import '/models/product.dart';

class AddSupplierScreen extends StatefulWidget {
  final Function(Supplier) onAddSupplier;

  const AddSupplierScreen({super.key, required this.onAddSupplier});

  @override
  AddSupplierScreenState createState() => AddSupplierScreenState();
}

class AddSupplierScreenState extends State<AddSupplierScreen> {


  final _formKey = GlobalKey<FormState>();
  final TextEditingController _iceController = TextEditingController();
  final TextEditingController _nameRespoController = TextEditingController();
  final TextEditingController _nameEntController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _activityController = TextEditingController();

  List<Product> products = [];

  List<Product> selectedActivities = [];
  String productId = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
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
        final newSupplier = Supplier(
          ice: _iceController.text,
          nameRespo: _nameRespoController.text,
          nameEnt: _nameEntController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          address: _addressController.text,
          products: selectedActivities,
        );

        final supplierCreated = await SupplierController.addSupplier(newSupplier);


        widget.onAddSupplier(supplierCreated);
        
        Provider.of<ActivityService>(context, listen: false).addActivity(
          "Ajout d'un nouveau fournisseur : ${newSupplier.nameRespo}",
          'shopping_bag',
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      Navigator.of(context).pop();
      print(e);
    }
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
                prefixIcon: const Icon(Icons.shopping_cart),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      textEditingController.clear();
                    });
                  },
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
    final theme = Provider.of<ThemeProvider>(context);
    return Dialog(
      backgroundColor: theme.dialogColor,
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
                  Text(
                    'Fournisseur',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.titleColor),
                    textAlign: TextAlign.left,
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
                decoration:InputDecoration(
                  labelText: 'ICE',
                  labelStyle: TextStyle(color: theme.textColor),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veillez renseigner l\'ice';
                  }
                  if (value.length != 15) {
                    return 'Le numéro ICE doit comporter 15 chiffres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Informations du fournisseur
              TextFormField(
                controller: _nameRespoController,
                decoration: InputDecoration(
                  labelText: 'Responsable',
                  labelStyle: TextStyle(color: theme.textColor),
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
                decoration: InputDecoration(
                  labelText: 'Entreprise',
                  labelStyle: TextStyle(color: theme.textColor),
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
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: theme.textColor),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  labelStyle: TextStyle(color: theme.textColor),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Adresse',
                  labelStyle: TextStyle(color: theme.textColor),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),

              _buildActivityAutocomplete(),
              const SizedBox(height: 24),

              // Bouton Enregistrer
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Enregistrer', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}