import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/client.dart';
import '/models/internal_order.dart';
import '../transactions_pages/details_internal_order.dart';

class ClientDetailsScreen extends StatelessWidget {
  final Client client;
  final List<InternalOrder> internalOrders; // Liste des commandes internes

  const ClientDetailsScreen({
    super.key,
    required this.client, required this.internalOrders,
  }); // Constructeur de la page

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    // Filtrer les commandes du client
    final clientOrders = internalOrders.where((order) => order.clientId == client.id).toList();

    // Calculer les statistiques des commandes
    final totalOrders = clientOrders.length;
    final pendingOrders = clientOrders.where((order) => order.status == OrderStatus.pending).length;
    final completedOrders = clientOrders.where((order) => order.status == OrderStatus.completed).length;
    final processingOrders = clientOrders.where((order) => order.status == OrderStatus.processing).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Détails du client',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white), // Flèche de retour en blanc
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Détails du client
            Text(
              'Informations du client',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Nom', client.name),
                    const SizedBox(height: 8),
                    _buildDetailRow('ICE', client.ice ?? 'N/A'),
                    const SizedBox(height: 8),
                    _buildDetailRow('Email', client.email),
                    const SizedBox(height: 8),
                    _buildDetailRow('Téléphone', client.phone),
                    const SizedBox(height: 8),
                    _buildDetailRow('Adresse', client.address),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Carte récapitulative des commandes
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
                    _buildStatCard('Total', totalOrders.toString(), Colors.blue),
                    _buildStatCard('En attente', pendingOrders.toString(), Colors.orange),
                    _buildStatCard('Traitement', processingOrders.toString(), Colors.yellow),
                    _buildStatCard('Complétées', completedOrders.toString(), Colors.green),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Liste des commandes
            Text(
              'Commandes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: theme.titleColor,
              ),
            ),
            const SizedBox(height: 8),
            _buildOrdersList(clientOrders),
          ],
        ),
      ),
    );
  }

  // Widget pour afficher une ligne de détail
  Widget _buildDetailRow(String label, String value) {
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
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  // Widget pour afficher une carte statistique
  Widget _buildStatCard(String label, String value, Color color) {
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
  Widget _buildOrdersList(List<InternalOrder> orders) {
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
                'C', // Première lettre de "Commande"
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text('Commande ID : ${order.id}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date : ${order.date}'),
                Text('Articles : ${order.items.length}'),
                Text(_getStatusText(order.status),
                    style: TextStyle(
                      color: order.status == OrderStatus.completed ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Action lors du clic sur une commande (par exemple, afficher les détails)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsInternalOrderScreen(order: order),
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