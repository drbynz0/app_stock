// ignore_for_file: use_build_context_synchronously

import 'package:cti_app/controller/supplier_controller.dart';
import 'package:cti_app/services/app_data_service.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/supplier.dart';
import 'add_supplier_screen.dart' as add_screen;
import 'edit_supplier_screen.dart';
import 'delete_supplier_screen.dart';
import 'supplier_details_screen.dart';

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
  
  Map<String, dynamic>? myPrivileges = {};
  Map<String, dynamic>? userData = {};

  @override
  void initState() {
    super.initState();
    _refreshOption();
  }

  Future<void> _refreshOption() async {
    final appData = Provider.of<AppData>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        appData.refreshDataService(context);
      }
    });

    if (appData.suppliers.isEmpty) {
      await appData.fetchSuppliers();
    }

    myPrivileges = appData.myPrivileges;
    userData = appData.userData;

    if (mounted) {
      setState(() {
        _suppliers = appData.suppliers;
      });
    }
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

  Future<void> _deleteSupplier(int? id) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    await SupplierController.deleteSupplier(id);
    await Provider.of<AppData>(context, listen: false).fetchSuppliers();
    await _refreshOption();
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    //final appData = Provider.of<AppData>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestion des Fournisseurs',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un fournisseur...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: InkWell(
                      onTap: () => _navigateToDetailsScreen(context, supplier),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    supplier.nameRespo,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: theme.nameColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    supplier.nameEnt,
                                    style: TextStyle(color: theme.secondaryTextColor, fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    supplier.phone,
                                    style: TextStyle(color: theme.secondaryTextColor, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            if ((userData?['is_staff'] ?? false) || 
                                (myPrivileges?['edit_supplier'] ?? false) || 
                                (myPrivileges?['delete_supplier'] ?? false))
                              Column(
                                children: [
                                  if ((userData?['is_staff'] ?? false) || (myPrivileges?['edit_supplier'] ?? false))
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'Modifier',
                                      onPressed: () => _showEditSupplierDialog(supplier),
                                    ),
                                  if ((userData?['is_staff'] ?? false) || (myPrivileges?['delete_supplier'] ?? false))
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
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredSuppliers.length} fournisseurs',
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
                      'Page $_currentPage/${(filteredSuppliers.length / _itemsPerPage).ceil()}',
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _currentPage < (filteredSuppliers.length / _itemsPerPage).ceil()
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
      floatingActionButton: ((userData?['is_staff'] ?? false) || (myPrivileges?['add_supplier'] ?? false))
          ? Padding(
              padding: const EdgeInsets.only(bottom: 55.0),
              child: FloatingActionButton(
                onPressed: () => _showAddSupplierDialog(),
                backgroundColor: const Color(0xFF004A99),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  void _showAddSupplierDialog() {
    showDialog(
      context: context,
      builder: (context) => add_screen.AddSupplierScreen(
        onAddSupplier: (newSupplier) async {
          await Provider.of<AppData>(context, listen: false).fetchSuppliers();
          await _refreshOption();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${newSupplier.nameRespo} est Ajouté avec succès'), 
                duration: const Duration(seconds: 3), 
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _showEditSupplierDialog(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => EditSupplierScreen(
        supplier: supplier,
        onEditSupplier: (updatedSupplier) async {
          await Provider.of<AppData>(context, listen: false).fetchSuppliers();
          await _refreshOption();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${updatedSupplier.nameRespo} est mise à jour avec succès'), 
                duration: const Duration(seconds: 3), 
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
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