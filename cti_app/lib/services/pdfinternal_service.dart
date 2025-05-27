import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/internal_order.dart';
import '../models/client.dart';

class PdfService {
  static Future<Uint8List> generateOrderDetails(InternalOrder order) async {
    final pdf = pw.Document();
    final clients = Client.getClients();
    final client = clients.firstWhere((c) => c.id == order.clientId, orElse: () => Client.empty());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // En-tête
              _buildHeader(order),
              pw.SizedBox(height: 20),
              
              // Section Informations Client
              _buildSectionTitle('Informations Client'),
              _buildClientInfoCard(order, client),
              pw.SizedBox(height: 20),
              
              // Section Prix
              _buildSectionTitle('Prix'),
              _buildPriceSection(order),
              pw.SizedBox(height: 20),
              
              // Section Articles
              _buildSectionTitle('Articles (${order.items.length})'),
              ...order.items.map((item) => _buildOrderItem(item)),
              pw.SizedBox(height: 20),
              
              // Section Description
              _buildDescriptionSection(order),
              pw.SizedBox(height: 20),
              
              // Total
              _buildTotalSection(order),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(InternalOrder order) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Détails de la Commande',
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.Text(
          'Client: ${order.clientName}',
          style: pw.TextStyle(fontSize: 16),
        ),
        pw.Text(
          'Date: ${order.date.day}/${order.date.month}/${order.date.year} à ${order.date.hour}h${order.date.minute.toString().padLeft(2, '0')}',
          style: pw.TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 18,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue900,
      ),
    );
  }

  static pw.Widget _buildClientInfoCard(InternalOrder order, Client client) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(5),
      ),
        padding: pw.EdgeInsets.all(15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Nom', order.clientName),
          _buildInfoRow('Date', '${order.date.day}/${order.date.month}/${order.date.year}'),
          _buildInfoRow('Statut', _getStatusText(order.status)),
          _buildInfoRow('Moyen de paiement', _getPaymentMethodText(order.paymentMethod)),
          if (client != Client.empty()) ...[
            _buildInfoRow('Téléphone', client.phone),
            _buildInfoRow('Email', client.email),
            _buildInfoRow('Adresse', client.address),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  static pw.Widget _buildPriceSection(InternalOrder order) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      padding: pw.EdgeInsets.all(10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildPriceItem('Prix total', '${order.totalPrice.toStringAsFixed(2)} DH', PdfColors.green),
          _buildPriceItem('Prix payé', '${order.paidPrice.toStringAsFixed(2)} DH', PdfColors.blue),
          _buildPriceItem('Prix restant', '${order.remainingPrice.toStringAsFixed(2)} DH', PdfColors.red),
        ],
      ),
    );
  }

  static pw.Widget _buildPriceItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 5),
        pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 5),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildOrderItem(OrderItem item) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      margin: pw.EdgeInsets.only(bottom: 8),
      padding: pw.EdgeInsets.all(10),
      child: pw.Row(
        children: [
          pw.Container(
            width: 40,
            height: 40,
            child: pw.Center(child: pw.Text('📦')),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(5),
          ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(item.productName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Quantité: ${item.quantity}'),
                pw.Text('Prix unitaire: ${item.unitPrice.toStringAsFixed(2)} DH'),
              ],
            ),
          ),
          pw.Text(
            '${(item.quantity * item.unitPrice).toStringAsFixed(2)} DH',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDescriptionSection(InternalOrder order) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      padding: pw.EdgeInsets.all(15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Description',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            order.description != null && order.description!.isNotEmpty
                ? order.description!
                : 'Aucune description',
            style: pw.TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalSection(InternalOrder order) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.blue900),
            borderRadius: pw.BorderRadius.circular(5),
          ),
          padding: pw.EdgeInsets.all(10),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Total: ${order.totalPrice.toStringAsFixed(2)} DH',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Payé: ${order.paidPrice.toStringAsFixed(2)} DH',
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.blue,
                ),
              ),
              pw.Text(
                'Reste: ${order.remainingPrice.toStringAsFixed(2)} DH',
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return 'En attente';
      case OrderStatus.processing: return 'En traitement';
      case OrderStatus.toPay: return 'À payer';
      case OrderStatus.completed: return 'Terminée';
      case OrderStatus.cancelled: return 'Annulée';
    }
  }

  static String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash: return 'Espèces';
      case PaymentMethod.card: return 'Carte bancaire';
      case PaymentMethod.virement: return 'Virement';
      case PaymentMethod.cheque: return 'Chèque';
    }
  }
}