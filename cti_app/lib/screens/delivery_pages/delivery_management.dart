import 'package:cti_app/controller/delivery_notes_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cti_app/models/delivery_note.dart';
import 'package:cti_app/screens/delivery_pages/delivery_note_detail_screen.dart';

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
    final deliveryNotes = await DeliveryNoteController.fetchDeliveryNotes();
    setState(() {
      _deliveryNotes = deliveryNotes;
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Bons à délivrer',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF003366),
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
                    // ignore: deprecated_member_use
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Rechercher un bon...',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
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
                        color: const Color.fromARGB(255, 194, 224, 240),
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
                            color: const Color.fromARGB(255, 194, 224, 240),
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
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color.fromARGB(255, 9, 10, 11),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Client: ${note.clientName}',
                                          style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 13),
                                        ),
                                        Text(
                                          'Date: ${_formatDate(note.date!)}',
                                          style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 13),
                                        ),
                                        Text(
                                          'Total: ${NumberFormat.currency(locale: 'fr', symbol: 'DH').format(note.totalAmount)}',
                                          style: TextStyle(
                                              color: Colors.grey[700],
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
