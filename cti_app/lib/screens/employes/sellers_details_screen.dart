// ignore_for_file: use_build_context_synchronously

import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/controller/user_controller.dart';

class SellerDetailScreen extends StatefulWidget {
  final Map<String, dynamic> seller;

  const SellerDetailScreen({super.key, required this.seller});

  @override
  State<SellerDetailScreen> createState() => _SellerDetailScreenState();
}

class _SellerDetailScreenState extends State<SellerDetailScreen> {
  bool canAddProduct = false;
  bool canEditProduct = false;
  bool canDeleteProduct = false;
  bool canAddCustomer = false;
  bool canEditCustomer = false;
  bool canDeleteCustomer = false;
  bool canAddOrder = false;
  bool canEditOrder = false;
  bool canDeleteOrder = false;
  bool canAddSupplier = false;
  bool canEditSupplier = false;
  bool canDeleteSupplier = false;
  bool canAddCategory = false;
  bool canEditCategory = false;
  bool canDeleteCategory = false;
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadSellerPrivileges();
  }

  Future<void> loadSellerPrivileges() async {
    setState(() {
      canAddProduct = widget.seller['privileges']['add_product'] ?? false;
      canEditProduct = widget.seller['privileges']['edit_product'] ?? false;
      canAddCustomer = widget.seller['privileges']['add_client'] ?? false;
      canEditCustomer = widget.seller['privileges']['edit_client'] ?? false;
      canDeleteCustomer = widget.seller['privileges']['delete_client'] ?? false;
      canAddOrder = widget.seller['privileges']['add_order'] ?? false;
      canEditOrder = widget.seller['privileges']['edit_order'] ?? false;
      canDeleteOrder = widget.seller['privileges']['delete_order'] ?? false;
      canDeleteProduct = widget.seller['privileges']['delete_product'] ?? false;
      canAddSupplier = widget.seller['privileges']['add_supplier'] ?? false;
      canEditSupplier = widget.seller['privileges']['edit_supplier'] ?? false;
      canDeleteSupplier = widget.seller['privileges']['delete_supplier'] ?? false;
      canAddCategory = widget.seller['privileges']['add_category'] ?? false;
      canEditCategory = widget.seller['privileges']['edit_category'] ?? false;
      canDeleteCategory = widget.seller['privileges']['delete_category'] ?? false;
      isLoading = false;
    });
  }

  Future<void> _updatePrivilege(String key, bool value) async {
    setState(() => isSaving = true);
    
    try {
      final success = await UserController.updateUserPrivileges(
        widget.seller['id'],
        {key: value},
      );

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erreur de mise à jour"),
            backgroundColor: Colors.red,
          ),
        );
        // Revert the change if update failed
        setState(() => _updateLocalPrivilege(key, !value));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _updateLocalPrivilege(key, !value));
    } finally {
      setState(() => isSaving = false);
    }
  }

  void _updateLocalPrivilege(String key, bool value) {
    switch (key) {
      case 'add_product': canAddProduct = value; break;
      case 'edit_product': canEditProduct = value; break;
      case 'delete_product': canDeleteProduct = value; break;
      case 'add_client': canAddCustomer = value; break;
      case 'edit_client': canEditCustomer = value; break;
      case 'delete_client': canDeleteCustomer = value; break;
      case 'add_order': canAddOrder = value; break;
      case 'edit_order': canEditOrder = value; break;
      case 'delete_order': canDeleteOrder = value; break;
      case 'add_supplier': canAddSupplier = value; break;
      case 'edit_supplier': canEditSupplier = value; break;
      case 'delete_supplier': canDeleteSupplier = value; break;
      case 'add_category': canAddCategory = value; break;
      case 'edit_category': canEditCategory = value; break;
      case 'delete_category': canDeleteCategory = value; break;
    }
  }

  Widget _buildInfoCard() {
    final theme = Provider.of<ThemeProvider>(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(Icons.person, color: Colors.blue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.seller['first_name']} ${widget.seller['last_name']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '@${widget.seller['username']}',
                        style: TextStyle(
                          color: theme.secondaryTextColor,
                        ),
                      ),
                      Text(
                        widget.seller['email'],
                        style: TextStyle(
                          color: theme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.phone, widget.seller['phone'] ?? 'Non fourni'),
            _buildInfoRow(Icons.work, widget.seller['user_type']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPrivilegeSection() {
    final theme = Provider.of<ThemeProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'PRIVILÈGES',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.titleColor,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Card(
          child: Column(
            children: [
              _buildSectionHeader('Gestion des Produits'),
              _buildPrivilegeSwitch(
                'add_product',
                'Ajouter des produits',
                canAddProduct,
              ),
              _buildPrivilegeSwitch(
                'edit_product',
                'Modifier des produits',
                canEditProduct,
              ),
              _buildPrivilegeSwitch(
                'delete_product',
                'Supprimer des produits',
                canDeleteProduct,
              ),
            ]
          ),
        ),
        SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Column(
            children: [
               _buildSectionHeader('Gestion des Clients'),
              _buildPrivilegeSwitch(
                'add_client',
                'Ajouter des clients',
                canAddCustomer,
              ),
              _buildPrivilegeSwitch(
                'edit_client',
                'Modifier des clients',
                canEditCustomer,
              ),
              _buildPrivilegeSwitch(
                'delete_client',
                'Supprimer des clients',
                canDeleteCustomer,
              ),
            ]
          ),
        ),
        SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              _buildSectionHeader('Gestion des Commandes'),
              _buildPrivilegeSwitch(
                'add_order',
                'Ajouter des commandes',
                canAddOrder,
              ),
              _buildPrivilegeSwitch(
                'edit_order',
                'Modifier des commandes',
                canEditOrder,
              ),
              _buildPrivilegeSwitch(
                'delete_order',
                'Supprimer des commandes',
                canDeleteOrder,
              ),
            ]
          ),
        ),
        SizedBox(height: 16),    
        Card(
          child: Column(
            children: [
              _buildSectionHeader('Gestion des Fournisseur'),
              _buildPrivilegeSwitch(
                'add_supplier',
                'Ajouter des fournisseurs',
                canAddSupplier,
              ),
              _buildPrivilegeSwitch(
                'edit_supplier',
                'Modifier des fournisseurs',
                canEditSupplier,
              ),
              _buildPrivilegeSwitch(
                'delete_supplier',
                'Supprimer des fournisseurs',
                canDeleteSupplier,
              ),
            ]
          ),
        ),
        SizedBox(height: 16),    
        Card(
          child: Column(
            children: [
              _buildSectionHeader('Gestion des Catégories'),
              _buildPrivilegeSwitch(
                'add_category',
                'Ajouter des catégories',
                canAddCategory,
              ),
              _buildPrivilegeSwitch(
                'edit_category',
                'Modifier des catégories',
                canEditCategory,
              ),
              _buildPrivilegeSwitch(
                'delete_category',
                'Supprimer des catégories',
                canDeleteCategory,
              ),
            ]
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildPrivilegeSwitch(String key, String title, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          if (isSaving)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Switch(
              value: value,
              onChanged: (newValue) {
                setState(() => _updateLocalPrivilege(key, newValue));
                _updatePrivilege(key, newValue);
              },
              activeColor: Colors.blue,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('${widget.seller['first_name']} ${widget.seller['last_name']}', style: const TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  _buildPrivilegeSection(),
                ],
              ),
            ),
    );
  }
}