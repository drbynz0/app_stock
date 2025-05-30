import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cti_app/models/delivery_note.dart';
import 'package:cti_app/services/delivery_note_service.dart';
import 'package:provider/provider.dart';


class DeliveryNoteDetailScreen extends StatelessWidget {
  final DeliveryNote note;

  const DeliveryNoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final currencyFormatter = NumberFormat.currency(locale: 'fr', symbol: 'DH', decimalDigits: 3);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Bon de Livraison',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Colors.white),
            onPressed: () async {
              final service = DeliveryNoteService();
              await service.printDeliveryNote(note);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSectionCard(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(note.clientName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(note.clientAddress, 
                      style: TextStyle(color: theme.secondaryTextColor)),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text("Date"),
                  subtitle: Text(_formatDate(note.date!), 
                      style: TextStyle(color: theme.secondaryTextColor)),
                ),
                ListTile(
                  leading: const Icon(Icons.badge),
                  title: const Text("Préparé par"),
                  subtitle: Text(note.preparedBy, 
                      style: TextStyle(color: theme.secondaryTextColor)
                    ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildArticlesCard(context, note),
            const SizedBox(height: 16),
            _buildSectionCard(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Montant Total',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      currencyFormatter.format(note.totalAmount),
                      style: TextStyle(
                        color: theme.titleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (note.comments != null && note.comments!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Commentaires",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildSectionCard(
                children: [
                  Text(
                    note.comments!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildArticlesCard(BuildContext context, DeliveryNote note) {
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
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.titleColor)),
            const Divider(),
            const SizedBox(height: 8),
            ...note.items.map((item) => _buildProductItem(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(DeliveryItem item) {
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
                Text(item.description,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Réf: ${item.productCode}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: Text('${item.quantity} x ${item.unitPrice.toStringAsFixed(3)}',
                textAlign: TextAlign.center),
          ),
          Expanded(
            child: Text('${total.toStringAsFixed(3)} DH',
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }
}
