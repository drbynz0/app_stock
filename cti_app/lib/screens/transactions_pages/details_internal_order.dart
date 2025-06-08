// ignore_for_file: use_build_context_synchronously

import 'package:cti_app/controller/facture_controller.dart';
import 'package:cti_app/controller/internal_orders_controller.dart';
import 'package:cti_app/services/app_data_service.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:cti_app/models/factures.dart';
import 'package:provider/provider.dart';
import '../../models/internal_order.dart';
import '/models/client.dart';
import '../client_pages/client_details_screen.dart';
import '../../services/pdfinternal_service.dart';
import '../factures_pages/details_facture_internal_screen.dart';

class DetailsInternalOrderScreen extends StatefulWidget {
  final InternalOrder order;

  const DetailsInternalOrderScreen({super.key, required this.order});

  @override
  DetailsInternalOrderScreenState createState() => DetailsInternalOrderScreenState();
}

class DetailsInternalOrderScreenState extends State<DetailsInternalOrderScreen> {
  late InternalOrder order;
  FactureClient facture = FactureClient.empty();
  List<Client> clients = [];
  List<InternalOrder> orders = [];
  AppData appData = AppData();
  List<FactureClient> internalFactures = [];


  @override
  void initState() {
    super.initState();
    _refreshOption();
  }

    // Méthode pour rafraîchir
  Future<void> _refreshOption() async {
    order = widget.order;
    final availableFactures = await FactureClientController.getFactures();
    appData = Provider.of<AppData>(context, listen: false);
    setState(() {
      internalFactures = availableFactures;
      clients = appData.clients;
      orders = appData.internalOrders;
    });
  }

  FactureClient getFacture(List<FactureClient> factures) {
    return factures.firstWhere(
      (facture) => facture.orderNum == order.orderNum,
      orElse: () => FactureClient.empty(),
    );
  }

  

  @override
  Widget build(BuildContext context) {
    final totalPrice = order.items.fold(0.0, (sum, item) => sum + (item.unitPrice * item.quantity));
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Commande de ${order.clientName}', style: const TextStyle(color: Colors.white)),
        actions: [
         IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              final pdfData = await PdfService.generateOrderDetails(order);
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
            // Section Informations Client
            _buildSectionHeader('Informations Client'),
            InkWell(
              onTap: () async {
                // Naviguer vers la page des détails du client
                final client = appData.getClientById(order.clientId!);
                if (client != Client.empty()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClientDetailsScreen(client: client, internalOrders: orders,),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Client introuvable')),
                  );
                }
              },
              child: _buildInfoCard(
                children: [
                  _buildInfoRow('Nom', order.clientName),
                  _buildInfoRow('Date', _formatDate(order.date)),
                  _buildInfoRow('Type de commande',_getTypeText(order.typeOrder)),
                  _buildInfoRow('Statut', _getStatusText(order.status)),
                  _buildInfoRow('Moyen de paiement', _getPaymentMethodText(order.paymentMethod)),
                  _buildInfoRow('Créée le', _formatDate(order.created!)),
                  _buildInfoRow('Modifiée le', _formatDate(order.updated!)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            //Section Prix
            Row(
              children: [
              _buildSectionHeader('Prix'),
              Spacer(),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showAddPaymentDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Ajouter Paiement', style: TextStyle(color: Colors.white)),
                ),
              ),
              ],
            ),
            _buildAllPrice(),
            const SizedBox(height: 24),

            // Section Articles
            _buildSectionHeader('Articles (${order.items.length})'),
            ...order.items.map((item) => _buildOrderItemCard(item)),
            const SizedBox(height: 16),

            // Section Total
            _buildDescriptionCard(totalPrice),
            const SizedBox(height: 24),

            //Section paiement
            _buildSectionHeader('Paiements'),
            const SizedBox(height: 16),
            FutureBuilder<List<Payments>>(
              future: InternalOrdersController.fetchPaymentsOrder(order.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Erreur: ${snapshot.error}');
                }
                final payments = snapshot.data ?? [];
                
                return Column(
                  children: payments.map((payment) => _buildPaymentItem(payment)).toList(),
                );
              },
            ),

            const SizedBox(height: 24),

            // Boutons d'action
              Row(
                children: [
                  if (order.status != OrderStatus.completed)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _changeOrderStatus(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.buttonColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Modifier Statut', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => {
                      facture = getFacture(internalFactures),
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InternalFactureDetailScreen(facture: facture, internalOrders: orders, clients: clients,),
                        ),
                      ),
                    },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.buttonColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Voir Facture', style: TextStyle(color: Colors.white)),
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
    final theme = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: theme.titleColor,
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Card(
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
    final theme = Provider.of<ThemeProvider>(context);
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
              // AppConstant.DEFAULT_IMAGE,
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
            Text('Quantité: ${item.quantity}', style: TextStyle(color: theme.secondaryTextColor)),
            Text('Prix unitaire: ${item.unitPrice.toStringAsFixed(2)} DH', style: TextStyle(color: theme.secondaryTextColor)),
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
    final theme = Provider.of<ThemeProvider>(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.titleColor)),
              const SizedBox(height: 8),
              Text(
                order.description != null && order.description!.isNotEmpty
                    ? order.description!
                    : 'Aucune description',
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
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildAllPriceItem(
              
              icon: Icons.attach_money,
              label: 'Prix total',
              value: '${order.totalPrice.toStringAsFixed(2)} MAD',
              color: Colors.green,
            ),
            _buildAllPriceItem(
              icon: Icons.payments,
              label: 'Prix payé',
              value: '${order.paidPrice.toStringAsFixed(2)} MAD',
              color: Colors.blue,
            ),
            _buildAllPriceItem(
              icon: Icons.pending_actions,
              label: 'Prix restant',
              value: '${order.remainingPrice.toStringAsFixed(2)} MAD',
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
            fontSize: 10,
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

  String _getTypeText(TypeOrder type) {
    switch (type) {
      case TypeOrder.online:
        return 'En ligne';
      case TypeOrder.inStore:
        return 'En magasin';
    }
  }

  Widget _buildPaymentItem(Payments payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.payment, color: Colors.green),
        title: Text(
          '${payment.totalPaid.toStringAsFixed(2)} DH',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${_getPaymentMethodText(payment.paymentMethod)} - ${payment.paidAt != null ? _formatDate(DateTime.parse(payment.paidAt!)) : 'Date inconnue'}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDeletePayment(context, payment),
        ),
      ),
    );
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
                        : 'Êtes-vous sûr de vouloir marquer cette commande comme "Annulée"? Cette action est irréversible.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final updatedStatus = await InternalOrdersController.updateOrderStatus(orderId: order.id, newStatus: newStatus.name);
                        setState(() {
                          order.status = newStatus;
                        });
                        
                        if(updatedStatus) {
                          // Ajouter la facture si le statut est "Terminée"
                          if (newStatus == OrderStatus.completed || newStatus == OrderStatus.toPay) {
                            FactureClient.addFactureForOrder(order, order.paidPrice);
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
                        }
                        Navigator.pop(context);
                        Navigator.pop(context, order);
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Statut mis à jour en ${_getStatusText(newStatus)}'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
              Navigator.pop(context, order);
            }
          }
        },
      ),
    ),
  );
}

  void _showAddPaymentDialog(BuildContext context) {
    final appData = Provider.of<AppData>(context, listen: false);
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    PaymentMethod selectedMethod = PaymentMethod.cash;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un paiement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant',
                  prefixText: 'DH ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Montant invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PaymentMethod>(
                value: selectedMethod,
                decoration: const InputDecoration(
                  labelText: 'Méthode de paiement',
                  border: OutlineInputBorder(),
                ),
                items: PaymentMethod.values.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(_getPaymentMethodText(method)),
                  );
                }).toList(),
                onChanged: (method) {
                  if (method != null) {
                    selectedMethod = method;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (optionnel)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez entrer un montant valide'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                // Créer le nouveau paiement
                final newPayment = Payments(
                  order: order.id!,
                  totalPaid: amount,
                  paymentMethod: selectedMethod,
                  note: noteController.text.isNotEmpty ? noteController.text : null,
                  paidAt: DateTime.now().toIso8601String(),
                );

                // Appeler l'API pour ajouter le paiement
                appData.addPayment(order.id!, newPayment);
                setState(() {
                  order.paidPrice += newPayment.totalPaid;
                  order.remainingPrice = order.totalPrice - order.paidPrice;
                });

                                        // Ajouter la facture si le statut est "Terminée"
                  FactureClient.updateFactureForOrder(order, order.paidPrice);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Statut mis à jour et facture créée'),
                      backgroundColor: Colors.green,
                    ),
                  );

                // Fermer le dialog
                Navigator.pop(context);

                // Afficher un message de succès
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Paiement ajouté avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

    void _confirmDeletePayment(BuildContext context, Payments payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce paiement?'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce paiement de ${payment.totalPaid} DH?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await InternalOrdersController.deletePayment(order.id!, payment.id!);
                
                setState(() {
                  order.paidPrice -= payment.totalPaid;
                  order.remainingPrice = order.totalPrice - order.paidPrice;
                });
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Paiement supprimé'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

}