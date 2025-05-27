import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../models/delivery_note.dart';

class DeliveryNoteService {
  final currencyFormatter = NumberFormat.currency(locale: 'fr', symbol: 'DH', decimalDigits: 2);

  Future<void> printDeliveryNote(DeliveryNote note) async {
    final pdf = pw.Document();

    final ByteData logoBytes = await rootBundle.load('assets/image/logo.png');
    final Uint8List logoUint8List = logoBytes.buffer.asUint8List();
    final logo = pw.MemoryImage(logoUint8List);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginTop: 0.5 * PdfPageFormat.cm,
          marginBottom: 1.5 * PdfPageFormat.cm,
          marginLeft: 1.0 * PdfPageFormat.cm,
          marginRight: 1.0 * PdfPageFormat.cm,
        ),
        header: (pw.Context context) => _buildHeader(logo),
        footer: (pw.Context context) => _buildFooter(context),
        build: (pw.Context context) => [
          _buildDeliveryTitle(note),
          pw.SizedBox(height: 10),
          _buildClientInfo(note),
          pw.SizedBox(height: 10),
          _buildItemsTable(note),
          pw.SizedBox(height: 10),
          _buildTotalAmount(note),
          if (note.comments != null && note.comments!.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Text('Commentaires :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(note.comments!),
          ],
          pw.SizedBox(height: 32),
          
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildHeader(pw.ImageProvider logo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      children: [
        pw.Container(height: 60, width: 60, child: pw.Image(logo)),
        pw.SizedBox(width: 10),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('CTI TECHNOLOGIE S.A.R.L AU', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text('Matériels Informatique - Fourniture et Mobilier de Bureau - Négocé', style: pw.TextStyle(fontSize: 8)),
            pw.Text('50 BD EL MARZALI BENI MELLAL', style: pw.TextStyle(fontSize: 8)),
            pw.Text('05 23 48 37 87', style: pw.TextStyle(fontSize: 8)),
            pw.Text('ctl.technologie@gmail.com - contact@ctitechnologie.ma', style: pw.TextStyle(fontSize: 8)),
            pw.Text('www.ctitechnologie.ma', style: pw.TextStyle(fontSize: 8)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              'Page ${context.pageNumber} sur ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 8),
            ),
          ],
        ),
        pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
          pw.SizedBox(height: 5),
          pw.Text(
            'RCN° : 4147 | Patente N° : 41950978 | JPN° : 40222830 | CNSS N° : 8512479 | ICE : 000097450000072',
            style: const pw.TextStyle(fontSize: 8),
          ),
          pw.Text(
            'Capital social : 200 000.00 Dhs|Compte Bancaire sur Banque populaire beni mellal Agence Al Horia N° : 145 090 212 112352109 0019 77',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ],
        ),
      ],
    );
  }

  pw.Widget _buildDeliveryTitle(DeliveryNote note) {
    return pw.Center(
      child: pw.Text(
        'BON DE LIVRAISON',
        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline),
      ),
    );
  }

  pw.Widget _buildClientInfo(DeliveryNote note) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Client : ${note.clientName}', style: const pw.TextStyle(fontSize: 10)),
          pw.Text('Adresse : ${note.clientAddress}', style: const pw.TextStyle(fontSize: 10)),
          pw.Text('Date : ${_formatDate(note.date!)}', style: const pw.TextStyle(fontSize: 10)),
          pw.Text('Préparé par : ${note.preparedBy}', style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }

 static pw.Widget _buildItemsTable(DeliveryNote note) {
  const tableHeight = 450.0;
  const headerHeight = 40.0;
  const totalRows = 30;

  final dataRows = note.items.map((item) {
    final total = item.quantity * item.unitPrice;
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        border: pw.Border.symmetric(
          vertical: pw.BorderSide(width: 0.5),
        ),
      ),
      children: [
        _buildTableCell(item.reference),
        _buildTableCell(item.description),
        _buildTableCell('${item.quantity}'),
        _buildTableCell('${total.toStringAsFixed(2)} DH'),
      ],
    );
  }).toList();

  final emptyRowCount = totalRows - dataRows.length;
  final emptyRows = List.generate(emptyRowCount, (index) => pw.TableRow(
    decoration: const pw.BoxDecoration(
      border: pw.Border.symmetric(),
    ),
    children: List.generate(4, (index) => pw.Container(
      padding: const pw.EdgeInsets.all(13),
      alignment: pw.Alignment.center,
      child: pw.Text('', style: const pw.TextStyle(fontSize: 10)),
    )),
  ));

  return pw.Container(
    height: tableHeight,
    padding: const pw.EdgeInsets.all(0),
    child: pw.Column(
      children: [
        // En-tête
        pw.Container(
          height: headerHeight,
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            border: pw.Border.all(width: 0.5),
            borderRadius: const pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          child: pw.Table(
            border: const pw.TableBorder(
              verticalInside: pw.BorderSide(width: 0.5),
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                children: [
                  _buildTableHeaderCell('Référence'),
                  _buildTableHeaderCell('Désignation'),
                  _buildTableHeaderCell('Quantité'),
                  _buildTableHeaderCell('Total'),
                ],
              ),
            ],
          ),
        ),

        // Données
        pw.Expanded(
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 0.5),
              borderRadius: const pw.BorderRadius.only(
                bottomLeft: pw.Radius.circular(8),
                bottomRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Table(
              border: pw.TableBorder(
                verticalInside: const pw.BorderSide(width: 0.5),
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1),
              },
              children: [...dataRows, ...emptyRows],
            ),
          ),
        ),
      ],
    ),
  );
}


  pw.Widget _buildTotalAmount(DeliveryNote note) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        'Montant Total : ${currencyFormatter.format(note.totalAmount)}',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  

  static pw.Widget _buildTableHeaderCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      alignment: pw.Alignment.center,
      child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
    );
  }

  static pw.Widget _buildTableCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      alignment: pw.Alignment.center,
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
    );
  }
}
