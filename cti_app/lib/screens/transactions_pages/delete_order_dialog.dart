import 'package:flutter/material.dart';

class DeleteOrderDialog extends StatelessWidget {
  final String orderId;
  final Function() onConfirm;

  const DeleteOrderDialog({
    super.key,
    required this.orderId,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Confirmer la suppression'),
      content: Text('Voulez-vous vraiment supprimer la commande #$orderId ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: Text('Supprimer', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}