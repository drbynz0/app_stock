import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/internal_order.dart';

class InternalOrderPdfService {
  static Future<Uint8List> generateInternalOrdersPdf(List<InternalOrder> orders) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // En-tête
              _buildHeader(),
              pw.SizedBox(height: 20),
              
              // Tableau des commandes
              _buildOrdersTable(orders),
              
              // Pied de page
              pw.SizedBox(height: 20),
              _buildFooter(orders.length),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Liste des Commandes Internes',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.Text(
              'Généré le: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
        pw.BarcodeWidget(
          data: 'CMD-${DateTime.now().millisecondsSinceEpoch}',
          barcode: pw.Barcode.qrCode(),
          width: 50,
          height: 50,
        ),
      ],
    );
  }

  static pw.Widget _buildOrdersTable(List<InternalOrder> orders) {
    // ignore: deprecated_member_use
    return pw.Table.fromTextArray(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerDecoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue900,
      ),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(8),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1.5),
        5: const pw.FlexColumnWidth(1.5),
      },
      headers: [
        'ID',
        'Client',
        'Date',
        'Articles',
        'Total (DH)',
        'Statut'
      ],
      data: orders.map((order) => [
        order.id,
        order.clientName,
        '${order.date.day}/${order.date.month}/${order.date.year}',
        order.items.length.toString(),
        order.totalPrice.toStringAsFixed(2),
        _getStatusText(order.status),
      ]).toList(),
    );
  }

  static pw.Widget _buildFooter(int totalOrders) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Total: $totalOrders commandes',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          'Page 1/1',
          style: const pw.TextStyle(fontSize: 10),
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
}