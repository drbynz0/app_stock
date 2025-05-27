import 'dart:typed_data';

import 'package:cti_app/controller/supplier_controller.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/external_order.dart';
import '../models/supplier.dart';

class PdfService {
  static Future<Uint8List> generateSupplierOrderDetails(ExternalOrder order) async {
    final pdf = pw.Document();
    final suppliers = await SupplierController.getSuppliers();
    final supplier = suppliers.firstWhere((s) => s.id == order.supplierId, orElse: () => Supplier.empty());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // En-tête
              _buildHeader(order),
              pw.SizedBox(height: 20),
              
              // Section Informations Fournisseur
              _buildSectionTitle('Informations Fournisseur'),
              _buildSupplierInfoCard(order, supplier),
              pw.SizedBox(height: 20),
              
              // Section Prix
              _buildSectionTitle('Prix'),
              _buildPriceSection(order),
              pw.SizedBox(height: 20),
              
              // Section Articles
              _buildSectionTitle('Articles (${order.items.length})'),
              ...order.items.map((item) => _buildOrderItem(item)),
              pw.SizedBox(height: 20),
              
              // Section Notes
              _buildNotesSection(order),
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

  static pw.Widget _buildHeader(ExternalOrder order) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Bon de Commande Fournisseur',
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.Text(
          'N° Commande: ${order.id}',
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

  static pw.Widget _buildSupplierInfoCard(ExternalOrder order, Supplier supplier) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      padding: const pw.EdgeInsets.all(15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildInfoRow('ICE', supplier.ice),
          _buildInfoRow('Fournisseur', supplier.nameRespo),
          _buildInfoRow('Entreprise', supplier.nameEnt),
          _buildInfoRow('Date', '${order.date.day}/${order.date.month}/${order.date.year}'),
          _buildInfoRow('Statut', _getStatusText(order.status)),
          _buildInfoRow('Moyen de paiement', _getPaymentMethodText(order.paymentMethod)),
          _buildInfoRow('Téléphone', supplier.phone),
          _buildInfoRow('Email', supplier.email),
          _buildInfoRow('Adresse', supplier.address),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
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

  static pw.Widget _buildPriceSection(ExternalOrder order) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildPriceItem('Prix total', '${order.totalPrice.toStringAsFixed(2)} DH', PdfColors.green),
          _buildPriceItem('Paiement effectué', '${order.paidPrice.toStringAsFixed(2)} DH', PdfColors.blue),
          _buildPriceItem('Reste à payer', '${order.remainingPrice.toStringAsFixed(2)} DH', PdfColors.red),
        ],
      ),
    );
  }

  static pw.Widget _buildPriceItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 12),
        ),
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
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Row(
        children: [
          pw.Container(
            width: 40,
            height: 40,
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Center(child: pw.Text('📦')),
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

  static pw.Widget _buildNotesSection(ExternalOrder order) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      padding: const pw.EdgeInsets.all(15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Notes',
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
                : 'Aucune note',
            style: const pw.TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalSection(ExternalOrder order) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.blue900),
            borderRadius: pw.BorderRadius.circular(5),
          ),
          padding: const pw.EdgeInsets.all(10),
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