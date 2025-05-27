// ignore_for_file: use_build_context_synchronously

import 'package:cti_app/controller/supplier_controller.dart';
import 'package:flutter/material.dart';
import '/models/supplier.dart';
import 'add_supplier_screen.dart' as add_screen;
import 'edit_supplier_screen.dart';
import 'delete_supplier_screen.dart';
import 'supplier_details_screen.dart'; // Import de la page des détails du fournisseur

class SuppliersManagementScreen extends StatefulWidget {
  const SuppliersManagementScreen({super.key});

  @override
  State<SuppliersManagementScreen> createState() => _SuppliersManagementScreenState();
}

class _SuppliersManagementScreenState extends State<SuppliersManagementScreen> {
  List<Supplier> _suppliers = [];
  int _currentPage = 1;
  final int _itemsPerPage = 5;
    String _searchQuery = '';


    @override
  void initState() {
    super.initState();
    _refreshOption();
  }

  // Méthode pour rafraîchir
  Future<void> _refreshOption() async {
    final availableSuppliers = await SupplierController.getSuppliers();
    setState(() {
      _suppliers = availableSuppliers;
    });
  }

  List<Supplier> get filteredSuppliers {
    return _suppliers.where((supplier) {
      return supplier.nameRespo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        supplier.nameEnt.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Supplier> get paginatedSuppliers {
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    endIndex = endIndex > filteredSuppliers.length ? filteredSuppliers.length : endIndex;
    return filteredSuppliers.sublist(startIndex, endIndex);
  }

  void _deleteSupplier(int? id) async {
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    await SupplierController.deleteSupplier(id);
    _refreshOption();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestion des Fournisseurs',
          style: TextStyle(color: Colors.white), // Texte en blanc
        ),
        backgroundColor: const Color(0xFF003366),
        iconTheme: const IconThemeData(color: Colors.white), // Icônes en blanc
        elevation: 4, // Ombre sous l'AppBar
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un client...',
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: paginatedSuppliers.length,
                itemBuilder: (context, index) {
                  final supplier = paginatedSuppliers[index];
                  return Card(
                    color: const Color.fromARGB(255, 194, 224, 240),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // Coins arrondis
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0), // Espacement entre les cartes
                    child: InkWell(
                      onTap: () => _navigateToDetailsScreen(context, supplier), // Lien vers les détails
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Badge avec les initiales du fournisseur
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: const Color(0xFF004A99),
                              child: Text(
                                supplier.nameRespo[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Informations du fournisseur
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    supplier.nameRespo,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black, // Couleur du titre en noir
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    supplier.nameEnt,
                                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    supplier.phone,
                                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            // Boutons d'action
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Color(0xFF004A99)),
                                  tooltip: 'Modifier',
                                  onPressed: () => _showEditSupplierDialog(supplier),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Supprimer',
                                  onPressed: () => _showDeleteDialog(context, supplier),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
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
                  '${_suppliers.length} fournisseurs',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _currentPage > 1
                          ? () => setState(() => _currentPage--)
                          : null,
                    ),
                    Text(
                      'Page $_currentPage/${(_suppliers.length / _itemsPerPage).ceil()}',
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _currentPage < (_suppliers.length / _itemsPerPage).ceil()
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 55.0), // Ajustez la valeur pour déplacer le bouton vers le haut
        child: FloatingActionButton(
          onPressed: () => _showAddSupplierDialog(),
          backgroundColor: const Color(0xFF004A99),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked, // Positionne le bouton à droite
    );
  }


  void _showAddSupplierDialog() {
    showDialog(
      context: context,
      builder: (context) => add_screen.AddSupplierScreen(
        onAddSupplier: (newSupplier) {
          _refreshOption();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${newSupplier.nameRespo} est Ajouté avec succès'), duration: const Duration(seconds: 3), backgroundColor: Colors.green,),
          );
          Navigator.pop(context);
        },
        
      ),
    );
  }

  void _showEditSupplierDialog(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => EditSupplierScreen(
        supplier: supplier,
        onEditSupplier: (updatedSupplier) {
          _refreshOption();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${updatedSupplier.nameRespo} est mise à jour avec succès'), duration: const Duration(seconds: 3), backgroundColor: Colors.green,),
          );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _navigateToDetailsScreen(BuildContext context, Supplier supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupplierDetailsScreen(supplier: supplier),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => DeleteSupplierScreen(
        onDelete: () => _deleteSupplier(supplier.id!),
        supplier: supplier,
      ),
    );
  }
}