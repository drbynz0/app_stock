import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/factures.dart';
import '../models/internal_order.dart';
import '../models/client.dart';

class InternalFactureService {
  static Future<void> generateAndPrintFacture({
    required InternalOrder internalOrder,
    required FactureClient facture,
    required BuildContext context,
    required Client client,
  }) async {
    try {
      final pdfBytes = await _generateFacturePdf(facture, client, internalOrder);
      await Printing.layoutPdf(onLayout: (format) => pdfBytes);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur génération facture: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

static Future<Uint8List> _generateFacturePdf(FactureClient facture, Client client, InternalOrder internalOrder) async {
  final pdf = pw.Document();
  final logo = await _getLogoImage();

  final double totalHT = facture.amount;
  final double tva = totalHT * 0.20;
  final double totalTTC = totalHT + tva;

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 0.5 * PdfPageFormat.cm, vertical: 0.5 * PdfPageFormat.cm),
      header: (pw.Context context) => _buildHeaderSection(logo, facture, client, context),
      footer: (pw.Context context) => pw.Column(
        children: [
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildPaymentConditionsTable(facture, internalOrder),
              ),
              pw.SizedBox(width: 30),
              pw.Expanded(
                child: _buildTotalsSection(totalHT, tva, totalTTC, internalOrder),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          _buildFooter(context),
        ]
      ),
      build: (pw.Context context) => [
        pw.SizedBox(height: 20),
        _buildProductsTable(internalOrder),
        pw.SizedBox(height: 6),
        _buildTotalsText(totalTTC, facture),
        pw.SizedBox(height: 10),
        
      ],
    ),
  );

  return pdf.save();
}

  static pw.Widget _buildHeaderSection(pw.ImageProvider logo, FactureClient facture, Client client, pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  _buildHeader(logo),
                  pw.SizedBox(height: 30),
                  _buildFollowedInfo()
                ],
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  _buildFactureTitle(facture),
                  pw.SizedBox(height: 6),
                  _buildFactureInfo(facture, client, context),
                  pw.SizedBox(height: 6),
                  _buildClientInfo(client, facture)
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildHeader(pw.ImageProvider logo) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          height: 60,
          width: 60,
          child: pw.Image(logo),
        ),
        pw.SizedBox(width: 10),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('CTI TECHNOLOGIE S.A.R.L AU', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.Text('Matériel Informatique - Fourniture et Mobilier', style: const pw.TextStyle(fontSize: 8)),
            pw.Text('50 BD EL HANSALI BENI MELLAL', style: const pw.TextStyle(fontSize: 8)),
            pw.Text('Tél: 05 23 48 37 87', style: const pw.TextStyle(fontSize: 8)),
            pw.Text('Email: contact@ctitechnologie.ma', style: const pw.TextStyle(fontSize: 8)),
            pw.Text('www.ctitechnologie.ma', style: const pw.TextStyle(fontSize: 8)),
          ],
        ),
      ],
    );
  }

    static pw.Widget _buildFollowedInfo() {
    return pw.Container(
      alignment: pw.Alignment.bottomLeft,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.5),
        borderRadius: pw.BorderRadius.circular(8), // Bordures arrondies
      ),
      child: pw.Table(
        border: pw.TableBorder.symmetric(
          inside: const pw.BorderSide(width: 0.5),
        ),
        columnWidths: {
          0: const pw.FlexColumnWidth(2),
        },
        children: [
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(3),
                child: pw.Text('Suivie par :', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(3),
                child: pw.Text('HADJAR', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(3),
                child: pw.Text('Affaire', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(3),
                child: pw.Text('', style: const pw.TextStyle(fontSize: 8)),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(3),
                child: pw.Text('V/Référence', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(3),
                child: pw.Text('BC N° N°CTL_BC128/24 -SDTM-CONTRE CHI', style: const pw.TextStyle(fontSize: 8)),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(3),
                child: pw.Text('N° bordereau exp', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(3),
                child: pw.Text('', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(3),
                child: pw.Text('Expédition', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(3),
                child: pw.Text('', style: const pw.TextStyle(fontSize: 8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFactureTitle(FactureClient facture) {
    return pw.Container(
      alignment: pw.Alignment.center,
      width: double.infinity,
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child:
          pw.Text('FACTURE N° ${facture.ref}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
    );
  }

  static pw.Widget _buildFactureInfo(FactureClient facture, Client client, pw.Context context) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.5),
        borderRadius: pw.BorderRadius.circular(8), // Bordures arrondies
      ),
      child: pw.Table(
        border: pw.TableBorder.symmetric(
          inside: const pw.BorderSide(width: 0.5),
        ),
        children: [
          pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(4),
                alignment: pw.Alignment.center,
                child: pw.Text('DATE', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(4),
                alignment: pw.Alignment.center,
                child: pw.Text('CLIENT', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(4),
                alignment: pw.Alignment.center,
                child: pw.Text('PAGE', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(4),
                alignment: pw.Alignment.center,
                child: pw.Text(facture.date, style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(4),
                alignment: pw.Alignment.center,
                child: pw.Text(client.id.toString(), style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(4),
                alignment: pw.Alignment.center,
                child: pw.Text('Page: ${context.pageNumber}/${context.pagesCount}', style: const pw.TextStyle(fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildClientInfo(Client client, FactureClient facture) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFD3D2D2),
        border: pw.Border.all(),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(facture.clientName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold )),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Text('ICE : ', style: const pw.TextStyle(fontSize: 10)),
              pw.Text(client.ice ?? 'N/A', style: const pw.TextStyle(fontSize: 10)),
            ]
          ),
          pw.Text(client.address, style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 10),
          pw.Text('Tél : ${client.phone}', style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

static pw.Widget _buildProductsTable(InternalOrder order) {
  const tableHeight = 460.0;
  const headerHeight = 40.0;
  const totalRows = 30;

  // Créer les lignes de données existantes
  final dataRows = order.items.map((item) => pw.TableRow(
    decoration: pw.BoxDecoration(
    border: pw.Border.symmetric(
      vertical: pw.BorderSide(width: 0.5),
    ),
  ),
    children: [
      _buildTableCell(item.productRef),
      _buildTableCell(item.productName),
      _buildTableCell('U'),
      _buildTableCell(item.quantity.toString()),
      _buildTableCell(item.unitPrice.toStringAsFixed(2)),
      _buildTableCell((item.quantity * item.unitPrice).toStringAsFixed(2)),
    ],
  )).toList();

  // Calcul du nombre de lignes vides nécessaires
  final emptyRowCount = totalRows - dataRows.length;

  // Créer des lignes vides si nécessaire
final emptyRows = List.generate(emptyRowCount, (index) => pw.TableRow(
  decoration: pw.BoxDecoration(
    border: pw.Border.symmetric(
    ),
  ),
  children: List.generate(6, (index) => pw.Container(
    padding: const pw.EdgeInsets.all(13),
    alignment: pw.Alignment.center,
    child: pw.Text('', style: pw.TextStyle(fontSize: 10)),
  )),
));

  return pw.Container(
    height: tableHeight,
    padding: const pw.EdgeInsets.all(0),
    decoration: pw.BoxDecoration(
    ),
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
            columnWidths: _getColumnWidths(),
            children: [
              pw.TableRow(
                children: [
                  _buildTableHeaderCell('Référence'),
                  _buildTableHeaderCell('Désignation'),
                  _buildTableHeaderCell('Unité'),
                  _buildTableHeaderCell('Qté'),
                  _buildTableHeaderCell('PU.HT'),
                  _buildTableHeaderCell('PT.HT'),
                ],
              ),
            ],
          ),
        ),

        // Données produits avec lignes vides complétées
        pw.Expanded(
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 0.5), // Bordure extérieure
              borderRadius: pw.BorderRadius.only(
                bottomLeft: pw.Radius.circular(8),
                bottomRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Table(
              border: pw.TableBorder(
                verticalInside: const pw.BorderSide(width: 0.5),
              ),
              columnWidths: _getColumnWidths(),
              children: [...dataRows, ...emptyRows],
            ),
          ),
        )
      ],
    ),
  );
}


static Map<int, pw.TableColumnWidth> _getColumnWidths() => {
  0: const pw.FlexColumnWidth(2),
  1: const pw.FlexColumnWidth(3),
  2: const pw.FlexColumnWidth(1),
  3: const pw.FlexColumnWidth(1),
  4: const pw.FlexColumnWidth(1.5),
  5: const pw.FlexColumnWidth(1.5),
};





  static pw.Widget _buildTotalsText(double totalTTC, FactureClient facture) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      children: [
        pw.Column(
         crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Arrêtée la Présente Facture à la somme de :',
              style: const pw.TextStyle(fontSize: 15),
            ),
            pw.Text(
              '${_numberToWords(totalTTC)} Dirhams. T.T.C',
              style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
        pw.SizedBox(width: 60),
        pw.Expanded(child: pw.Text('Fait le : ${facture.date} à Béni Mellal', style: pw.TextStyle(fontSize: 10)))
      ]      
    );
  }

    static pw.Widget _buildTotalsSection(double totalHT, double tva, double totalTTC, InternalOrder order) {
      return pw.Column(
        children: [
          pw.Container(
            width: double.infinity,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 0.5),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Table(
              border: pw.TableBorder.symmetric(inside: const pw.BorderSide(width: 0.5)),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.only(
                      topLeft: pw.Radius.circular(8),
                      topRight: pw.Radius.circular(8),
                    ),
                  ),
                  children: [
                    _buildTableHeaderCell('T.H.T'),
                    _buildTableHeaderCell('T.V.A 20%'),
                    _buildTableHeaderCell('TOTAL T.T.C'),
                  ],
                ),
                // Exemple avec données dynamiques
                pw.TableRow(
                  children: [
                    _buildTableCell(totalHT.toStringAsFixed(3)),
                    _buildTableCell(tva.toStringAsFixed(3)),
                    _buildTableCell(totalTTC.toStringAsFixed(3)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Container(
            alignment: pw.Alignment.center,
            width: double.infinity,
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text('NET A PAYER : ${totalTTC.toStringAsFixed(3)} MAD', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          ),
        ],
      );

  }

  static pw.Widget _buildPaymentConditionsTable(FactureClient facture, InternalOrder order) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 0.5),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
            ),
            padding: const pw.EdgeInsets.all(4),
            alignment: pw.Alignment.center,
            child: pw.Text('CONDITIONS DE REGLEMENT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue900,)),
          ),
          pw.Table(
            border: pw.TableBorder.symmetric(inside: const pw.BorderSide(width: 0.5)),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.only(
                  ),
                ),
                children: [
                  _buildTableHeaderCell('N°'),
                  _buildTableHeaderCell('MONTANT'),
                  _buildTableHeaderCell('MODE'),
                  _buildTableHeaderCell('ECHEANCE'),
                ],
              ),
              // Exemple avec données dynamiques
              pw.TableRow(
                children: [
                  _buildTableCell('1'),
                  _buildTableCell(facture.amount.toStringAsFixed(3)),
                  _buildTableCell(_getPaymentMethodText(order.paymentMethod)),
                  _buildTableCell(_formatDate(order.date)),
                ],
              ),
            ],
          ),
        ]
      )

    );
  }

  static String getPageNumber(pw.Context context) {
    return 'Page ${context.pageNumber} / ${context.pagesCount}';
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.center,
      child: pw.Column(
        children: [
          pw.SizedBox(height: 5),
          pw.Text(
            'RCN° : 4147 | Patente N° : 41950978 | JPN° : 40222830 | CNSS N° : 8512479 | ICE : 000097450000072',
            style: const pw.TextStyle(fontSize: 8),
          ),
          pw.Text(
            'Capital social : 200 000.00 Dhs Compte Bancaire sur Banque populaire Béni Mellal Agence Al Horia N° : 145 090 212 112352109 0019 77',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ],
      ),

    );
  }

  static pw.Widget _buildTableHeaderCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      alignment: pw.Alignment.center,
      child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue900,)),
    );
  }

  static pw.Widget _buildTableCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(3),
      alignment: pw.Alignment.center,
      child: pw.Text(text, style: pw.TextStyle(fontSize: 10)),
    );
  }

  static Future<pw.ImageProvider> _getLogoImage() async {
    final ByteData logoData = await rootBundle.load('assets/image/logo.png');
    return pw.MemoryImage(logoData.buffer.asUint8List());
  }



  static String _numberToWords(double number) {
    final units = [
      '',
      'Un',
      'Deux',
      'Trois',
      'Quatre',
      'Cinq',
      'Six',
      'Sept',
      'Huit',
      'Neuf',
      'Dix',
      'Onze',
      'Douze',
      'Treize',
      'Quatorze',
      'Quinze',
      'Seize',
      'Dix-sept',
      'Dix-huit',
      'Dix-neuf'
    ];

    final tens = [
      '',
      '',
      'Vingt',
      'Trente',
      'Quarante',
      'Cinquante',
      'Soixante',
      'Soixante-dix',
      'Quatre-vingt',
      'Quatre-vingt-dix'
    ];

    String convertBelowThousand(int n) {
      if (n == 0) return '';
      if (n < 20) return units[n];
      if (n < 100) {
        int ten = n ~/ 10;
        int unit = n % 10;

        String tenText = tens[ten];
        if (ten == 7 || ten == 9) {
          return tens[ten - 1] +
              (unit == 1 ? '-et-' : '-') +
              units[10 + unit].toLowerCase();
        } else {
          return tenText + (unit == 1 && ten != 8 ? '-et-' : (unit > 0 ? '-' : '')) + units[unit].toLowerCase();
        }
      } else {
        int hundred = n ~/ 100;
        int remainder = n % 100;

        String hundredText =
            (hundred > 1 ? '${units[hundred]} Cent' : 'Cent') +
                (remainder == 0 ? '' : ' ');
        return hundredText + convertBelowThousand(remainder).toLowerCase();
      }
    }

    int intPart = number.toInt();

    if (intPart == 0) return 'Zéro';

    String result = '';

    if (intPart >= 1000) {
      int thousands = intPart ~/ 1000;
      int remainder = intPart % 1000;

      if (thousands == 1) {
        result += 'Mille';
      } else {
        result += '${convertBelowThousand(thousands)} Mille';
      }

      if (remainder > 0) {
        result += ' ${convertBelowThousand(remainder)}';
      }
    } else {
      result = convertBelowThousand(intPart);
    }

    return result.trim()[0].toUpperCase() + result.trim().substring(1);
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
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