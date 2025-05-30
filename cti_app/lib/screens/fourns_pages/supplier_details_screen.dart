import 'package:cti_app/models/product.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/supplier.dart';
import '/models/external_order.dart';
import '../transactions_pages/details_external_order_screen.dart';

class SupplierDetailsScreen extends StatelessWidget {
  final Supplier supplier;
  final List<ExternalOrder> externalOrders;

  const SupplierDetailsScreen({super.key, required this.supplier, required this.externalOrders});
  // Constructeur pour initialiser le fournisseur et les commandes externes;

  @override
  Widget build(BuildContext context) {
    
    final supplierOrders = externalOrders.where((order) => order.supplierId == supplier.id).toList();
    final totalOrders = supplierOrders.length;
    final pendingOrders = supplierOrders.where((order) => order.status == OrderStatus.pending).length;
    final completedOrders = supplierOrders.where((order) => order.status == OrderStatus.completed).length;
    final processingOrders = supplierOrders.where((order) => order.status == OrderStatus.processing).length;
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Détails du Fournisseur',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Informations du fournisseur
            Text(
              'Informations du Fournisseur',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: theme.titleColor
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(context, 'ICE', supplier.ice),
                    const SizedBox(height: 8),
                    _buildDetailRow(context, 'Responsable', supplier.nameRespo),
                    const SizedBox(height: 8),
                    _buildDetailRow(context, 'Service', supplier.nameEnt),
                    const SizedBox(height: 8),
                    _buildDetailRow(context, 'Email', supplier.email),
                    const SizedBox(height: 8),
                    _buildDetailRow(context, 'Téléphone', supplier.phone),
                    const SizedBox(height: 8),
                    _buildDetailRow(context, 'Adresse', supplier.address),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section Produits fournis
            Text(
              'Activités',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: theme.titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildProductsList(supplier.products),
              ),
            ),
            const SizedBox(height: 24),

            // Section Statistiques des commandes
            Text(
              'Statistiques des Commandes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: theme.titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(context, 'Total', totalOrders.toString(), Colors.blue),
                    _buildStatCard(context, 'En attente', pendingOrders.toString(), Colors.orange),
                    _buildStatCard(context, 'Traitement', processingOrders.toString(), Colors.yellow),
                    _buildStatCard(context, 'Complétées', completedOrders.toString(), Colors.green),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section Liste des commandes
            Text(
              'Commandes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: theme.titleColor
              ),
            ),
            const SizedBox(height: 8),
            _buildOrdersList(context, supplierOrders),
          ],
        ),
      ),
    );
  }

  // Widget pour afficher la liste des produits
  Widget _buildProductsList(List<Product> products) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Aucun produit enregistré',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Column(
      children: products.map((product) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.network(
                product.images[0],
                  // AppConstant.DEFAULT_IMAGE,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported, color: Colors.grey);
                  },
                ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Ref: ${product.code}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Cat: ${product.category.name}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              )

            ),
          ],
        ),
      )).toList(),
    );
  }

  // Widget pour afficher une ligne de détail
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Provider.of<ThemeProvider>(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label : ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: theme.secondaryTextColor,
            ),
          ),
        ),
      ],
    );
  }

  // Widget pour afficher une carte statistique
  Widget _buildStatCard(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // Widget pour afficher la liste des commandes
  Widget _buildOrdersList(BuildContext context, List<ExternalOrder> orders) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF004A99),
              child: Text(
                'C',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text('Commande ID : ${order.id}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date : ${order.date}'),
                Text('Articles : ${order.items.length}'),
                Text(
                  _getStatusText(order.status),
                  style: TextStyle(
                    color: order.status == OrderStatus.completed ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsExternalOrderScreen(order: order),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Méthode pour obtenir le texte du statut
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