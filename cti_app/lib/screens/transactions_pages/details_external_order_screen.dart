// ignore_for_file: use_build_context_synchronously

import 'package:cti_app/controller/external_orders_controller.dart';
import 'package:cti_app/controller/supplier_controller.dart';
import 'package:cti_app/models/external_order.dart';
import 'package:flutter/material.dart';
import 'package:cti_app/models/factures.dart';
import 'package:cti_app/models/supplier.dart';
import 'package:url_launcher/url_launcher.dart';
import '../fourns_pages/supplier_details_screen.dart';
import '../../services/pdfexternel_service.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';


class DetailsExternalOrderScreen extends StatefulWidget {
  final ExternalOrder order;

  const DetailsExternalOrderScreen({super.key, required this.order});

  @override
  DetailsExternalOrderScreenState createState() => DetailsExternalOrderScreenState();
}

class DetailsExternalOrderScreenState extends State<DetailsExternalOrderScreen> {
  late ExternalOrder order;
  Supplier supplier = Supplier.empty();
  List<Supplier> suppliers = [];
  List<ExternalOrder> orders = [];



  @override
  void initState() {
    super.initState();
    order = widget.order;
    _refreshOption();
  }

    // Méthode pour rafraîchir
  Future<void> _refreshOption() async {
    final getSupplier = await SupplierController.getSupplierById(order.supplierId!);
    final availableSuppliers = await SupplierController.getSuppliers();
    final availableOrders = await ExternalOrdersController.fetchOrders();
    setState(() {
      supplier = getSupplier;
      suppliers = availableSuppliers;
      orders = availableOrders;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = order.items.fold(0.0, (sum, item) => sum + (item.unitPrice * item.quantity));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Achat avec ${order.supplierName}', style: const TextStyle(color: Colors.white)),
        actions: [
         IconButton(
  icon: const Icon(Icons.print),
    onPressed: () async {
            final pdfData = await PdfService.generateSupplierOrderDetails(order);
            await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfData);
          },

)
        ],
      ),
      body: SingleChildScrollView(
        
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Informations Fournisseur
            _buildSectionHeader('Informations Fournisseur'),
            InkWell(
              onTap: () async {

                // Naviguer vers la page des détails du fournisseur
                if (supplier != Supplier.empty()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SupplierDetailsScreen(supplier: supplier),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fournisseur introuvable')),
                  );
                }
              },

              child: _buildInfoCard(
                children: [
                  _buildInfoRow('ICE', supplier.ice),
                  _buildInfoRow('Fournisseur', supplier.nameRespo),
                  _buildInfoRow('Entreprise', supplier.nameEnt),
                  _buildInfoRow('Email', supplier.email),
                  _buildInfoRow('Adresse', supplier.address),
                  _buildInfoRow('Date', _formatDate(order.date)),
                  _buildInfoRow('Statut', _getStatusText(order.status)),
                  _buildInfoRow('Moyen de paiement', _getPaymentMethodText(order.paymentMethod)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section Prix
            _buildSectionHeader('Prix'),
            _buildAllPrice(),
            const SizedBox(height: 24),

            // Section Articles
            _buildSectionHeader('Articles (${order.items.length})'),
            ...order.items.map((item) => _buildOrderItemCard(item)),
            const SizedBox(height: 16),

            // Section Description
            _buildDescriptionCard(totalPrice),
            const SizedBox(height: 24),

            // Boutons d'action
              Row(
                children: [
                  if (order.status != OrderStatus.completed)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _changeOrderStatus(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 41, 160, 220),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Modifier Statut', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _sendConfirmation(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF004A99),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Confirmer Réception', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF003366),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Card(
      color: const Color.fromARGB(255, 194, 224, 240),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildOrderItemCard(OrderItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.network(
            item.productImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported, color: Colors.grey);
              },
            ),
        ),
        title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quantité: ${item.quantity}'),
            Text('Prix unitaire: ${item.unitPrice.toStringAsFixed(2)} DH'),
          ],
        ),
        trailing: Text(
          '${(item.quantity * item.unitPrice).toStringAsFixed(2)} DH',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(double total) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF003366))),
              const SizedBox(height: 8),
              Text(
                order.description != null && order.description!.isNotEmpty
                    ? order.description!
                    : 'Aucune note',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget _buildAllPrice() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildAllPriceItem(
              icon: Icons.attach_money,
              label: 'Prix total',
              value: '${order.totalPrice.toStringAsFixed(2)} DH',
              color: Colors.green,
            ),
            _buildAllPriceItem(
              icon: Icons.payments,
              label: 'Paiement effectué',
              value: '${order.paidPrice.toStringAsFixed(2)} DH',
              color: Colors.blue,
            ),
            _buildAllPriceItem(
              icon: Icons.pending_actions,
              label: 'Reste à payer',
              value: '${order.remainingPrice.toStringAsFixed(2)} DH',
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllPriceItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 30, color: color),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return 'En attente';
      case OrderStatus.processing: return 'En traitement';
      case OrderStatus.toPay: return 'À payer';
      case OrderStatus.completed: return 'Terminée';
      case OrderStatus.cancelled: return 'Annulée';
    }
  }

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash: return 'Espèces';
      case PaymentMethod.card: return 'Carte bancaire';
      case PaymentMethod.virement: return 'Virement';
      case PaymentMethod.cheque: return 'Chèque';
    }
  }

  

  void _changeOrderStatus(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Modifier le statut'),
      content: DropdownButtonFormField<OrderStatus>(
        decoration: const InputDecoration(
          labelText: 'Sélectionnez le statut',
          border: OutlineInputBorder(),
        ),
        value: order.status,
        items: OrderStatus.values.map((status) {
          return DropdownMenuItem(
            value: status,
            child: Text(_getStatusText(status)),
          );
        }).toList(),
        onChanged: (newStatus) {
          if (newStatus != null) {
            if (newStatus == OrderStatus.completed || newStatus == OrderStatus.cancelled) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmation'),
                  content: Text(
                    newStatus == OrderStatus.completed
                        ? 'Êtes-vous sûr de vouloir marquer cette commande comme "Terminée"? Cette action créera une facture.'
                        : 'Êtes-vous sûr de vouloir annuler cette commande?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          order.status = newStatus;
                        });
                        
                        // Ajouter la facture si le statut est "Terminée"
                        if (newStatus == OrderStatus.completed) {
                          FactureFournisseur.addFactureForOrder(order);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Statut mis à jour et facture créée'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Statut mis à jour en ${_getStatusText(newStatus)}'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                        
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Confirmer'),
                    ),
                  ],
                ),
              );
            } else {
              setState(() {
                order.status = newStatus;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Statut mis à jour en ${_getStatusText(newStatus)}'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        },
      ),
    ),
  );
}

void _sendConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmer réception'),
      content: const Text('Voulez-vous confirmer la réception de cette commande?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () async {
            // Afficher un indicateur de chargement
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(child: CircularProgressIndicator()),
            );
            final updatedStatus = await ExternalOrdersController.updateOrderStatus(
              orderId: order.id,
              newStatus: OrderStatus.completed.name,
            );
            Navigator.pop(context);
            if (updatedStatus) {
              setState(() {
                order.status = OrderStatus.completed;
              });

 // Construire le message détaillé
              StringBuffer message = StringBuffer();
              message.writeln('Bonjour ${order.supplierName},\n');
              message.writeln('Nous confirmons la réception de la commande n°${order.orderNum}.');
              message.writeln('\nDétails de la commande :\n');

              for (var item in order.items) {
                message.writeln('- ${item.productName} : ${item.quantity} x ${item.unitPrice} MAD');
              }

              message.writeln('\nTotal payé : ${order.paidPrice} €');
              message.writeln('Merci pour votre service.\n\nCordialement,\nL\'équipe CTI.\n Le ${_formatDate(order.date)}');

              final email = Uri(
                scheme: 'mailto',
                path: supplier.email,
                query: Uri.encodeFull(
                  'subject=Confirmation de réception commande n°${order.orderNum}&'
                  'body=${message.toString()}',
                ),
              );

              if (await canLaunchUrl(email)) {
                await launchUrl(email);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Impossible d’ouvrir l’application d’email.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Réception confirmée'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: const Text('Confirmer'),
        ),
      ],
    ),
  );
}

}