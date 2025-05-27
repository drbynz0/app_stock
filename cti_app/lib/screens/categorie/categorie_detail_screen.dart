import 'package:flutter/material.dart';
import '/models/category.dart';
class CategorieDetailScreen extends StatelessWidget {
  final Category categorie;
  const CategorieDetailScreen({super.key, required this.categorie});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la Catégorie'
            , style: TextStyle(color: Colors.white)), 
        backgroundColor: const Color(0xFF003366),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildDetailRow("ID", "${categorie.id}"),
                    buildDetailRow("Nom", categorie.name),
                    buildDetailRow("Slug", categorie.description ?? ''),
                    buildDetailRow("Créée le", _formatDate(categorie.createdAt!)),
                    buildDetailRow("Modifiée le", _formatDate(categorie.updatedAt!)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  } //
  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }
}