import 'package:flutter/material.dart';
import '../../models/product.dart';

class DeleteProductScreen extends StatelessWidget {
  final Product product;
  final Function() onDeleteConfirmed;

  const DeleteProductScreen({
    super.key,
    required this.product,
    required this.onDeleteConfirmed,
  });


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmer la suppression'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Voulez-vous vraiment supprimer le produit :'),
          SizedBox(height: 8),
          Text(
            product.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 4),
          Text('Catégorie: ${product.category.name}'),
          SizedBox(height: 16),
          Text(
            'Cette action est irréversible.',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Annuler', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            onDeleteConfirmed();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text('Supprimer'),
        ),
      ],
      

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}