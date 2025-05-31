import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cti_app/models/supplier.dart';
import 'package:provider/provider.dart';
import '/models/factures.dart';
import '/models/external_order.dart';
import '/services/external_facture_service.dart';

class ExternalFactureDetailScreen extends StatelessWidget {
  final FactureFournisseur facture;
  final List<ExternalOrder> externalOrders;
  final List<Supplier> suppliers;


  const ExternalFactureDetailScreen({
    super.key,
    required this.facture,
    required this.externalOrders,
    required this.suppliers,
  });

  @override
  Widget build(BuildContext context) {
    final order = externalOrders.firstWhere((order) => order.orderNum == facture.orderNum, orElse: () => ExternalOrder.empty());
    final supplier = suppliers.firstWhere((supplier) => supplier.id == order.supplierId, orElse: () => Supplier.empty());

    final double totalHT = facture.amount;
    final double tva = totalHT * 0.20;
    final double totalTTC = totalHT + tva;
    final double paidAmount = order.paidPrice;
    final double remainingAmount = order.remainingPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail Facture', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Colors.white),
            onPressed: () => ExternalFactureService.generateAndPrintFacture(
              externalOrder: order,
              facture: facture,
              context: context,
              supplier: supplier,
            ),          
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSupplierCard(context),
            const SizedBox(height: 24),
            _buildProductList(context, order),
            const SizedBox(height: 24),
            _buildAmountSection(context, totalHT, tva, totalTTC),
            const SizedBox(height: 24),
            _buildPaymentStatus(context, paidAmount, remainingAmount),
            const SizedBox(height: 24),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FACTURE #${facture.ref}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Date: ${facture.date}', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierCard(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final order = externalOrders.firstWhere((order) => order.orderNum == facture.orderNum, orElse: () => ExternalOrder.empty());
    final supplier = suppliers.firstWhere((supplier) => supplier.id == order.supplierId, orElse: () => Supplier.empty());
    return Card(
      // ...
      child: Column(

        children: [
           Text('FOURNISSEUR',  // Changer 'CLIENT' par 'FOURNISSEUR'
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color:  theme.titleColor)),
          const Divider(),
          const SizedBox(height: 8),
          _buildInfoRow('Raison sociale', supplier.nameRespo),
          _buildInfoRow('ICE', supplier.ice),
          _buildInfoRow('Adresse', supplier.address),
          _buildInfoRow('Téléphone', supplier.phone),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        children: [
          Text('$label : ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildProductList(BuildContext context, ExternalOrder order) {
    final theme = Provider.of<ThemeProvider>(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ARTICLES',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.titleColor)),
            const Divider(),
            const SizedBox(height: 8),
            ...order.items.map((item) => _buildProductItem(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(OrderItem item) {

    final total = item.unitPrice * item.quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Réf: ${item.productId}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: Text('${item.quantity} x ${item.unitPrice.toStringAsFixed(2)}',
                textAlign: TextAlign.center),
          ),
          Expanded(
            child: Text('${total.toStringAsFixed(2)} DH',
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(BuildContext context, double totalHT, double tva, double totalTTC) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAmountRow(context, 'Total HT:', totalHT),
            _buildAmountRow(context, 'TVA (20%):', tva),
            const Divider(thickness: 1.5),
            _buildAmountRow(context, 'TOTAL TTC:', totalTTC, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatus(BuildContext context, double paidAmount, double remainingAmount) {
    final theme = Provider.of<ThemeProvider>(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('STATUT DE PAIEMENT',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.titleColor)),
            const Divider(),
            const SizedBox(height: 8),
            _buildAmountRow(context, 'Montant payé:', paidAmount),
            _buildAmountRow(context, 'Reste à payer:', remainingAmount),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: facture.isPaid ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                facture.isPaid ? 'FACTURE PAYÉE' : 'EN ATTENTE DE PAIEMENT',
                style: TextStyle(
                  color: facture.isPaid ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(BuildContext context, String label, double amount, {bool isTotal = false}) {
        final theme = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              )),
          Text('${amount.toStringAsFixed(2)} DH',
              style: TextStyle(
                fontSize: isTotal ? 18 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? theme.titleColor : theme.textColor,
              )),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text('Merci pour votre confiance!', style: TextStyle(fontStyle: FontStyle.italic)),
        const SizedBox(height: 16),
        Text('Date d\'échéance: ${_calculateDueDate(facture.date)}',
            style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  String _calculateDueDate(String invoiceDate) {
    final date = DateFormat('dd/MM/yyyy').parse(invoiceDate);
    final dueDate = date.add(const Duration(days: 30));
    return DateFormat('dd/MM/yyyy').format(dueDate);
  }

}
