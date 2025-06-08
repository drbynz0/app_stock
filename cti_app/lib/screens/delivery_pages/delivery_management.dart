// ignore_for_file: deprecated_member_use

import 'package:cti_app/services/app_data_service.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cti_app/models/delivery_note.dart';
import 'package:cti_app/screens/delivery_pages/delivery_note_detail_screen.dart';
import 'package:provider/provider.dart';

class DeliveryNotesScreen extends StatefulWidget {
  const DeliveryNotesScreen({super.key});

  @override
  State<DeliveryNotesScreen> createState() => _DeliveryNotesScreenState();
}

class _DeliveryNotesScreenState extends State<DeliveryNotesScreen> {
  List<DeliveryNote> _deliveryNotes = [];
  List<DeliveryNote> _filteredNotes = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDeliveryNotes();
    _searchController.addListener(_filterNotes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadDeliveryNotes() async {
    final appData = Provider.of<AppData>(context, listen: false);
    setState(() {
      _deliveryNotes = appData.deliveryNotes;
      _filteredNotes = _deliveryNotes;
    });
  }

  void _filterNotes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotes = _deliveryNotes.where((note) {
        return note.noteNumber.toLowerCase().contains(query) ||
            note.clientName.toLowerCase().contains(query) ||
            DateFormat('dd/MM/yyyy').format(note.date!).contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bons à délivrer',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barre de recherche comme ClientManagementScreen
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // décalage de l'ombre
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Rechercher un bon...',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Liste des bons filtrés
            Expanded(
              child: _filteredNotes.isEmpty
                  ? Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _searchController.text.isEmpty
                                ? 'Aucun bon à délivrer trouvé'
                                : 'Aucun résultat pour "${_searchController.text}"',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredNotes.length,
                      itemBuilder: (context, index) {
                        final note = _filteredNotes[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DeliveryNoteDetailScreen(note: note),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.blue.shade900,
                                    child: Icon(Icons.receipt_long,
                                        color: Colors.white, size: 28),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Bon n° ${note.noteNumber}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: theme.titleColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Client: ${note.clientName}',
                                          style: TextStyle(
                                              color: theme.secondaryTextColor,
                                              fontSize: 13),
                                        ),
                                        Text(
                                          'Date: ${_formatDate(note.date!)}',
                                          style: TextStyle(
                                              color: theme.secondaryTextColor,
                                              fontSize: 13),
                                        ),
                                        Text(
                                          'Total: ${NumberFormat.currency(locale: 'fr', symbol: 'DH').format(note.totalAmount)}',
                                          style: TextStyle(
                                              color: theme.secondaryTextColor,
                                              fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios,
                                      size: 18, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }
}
