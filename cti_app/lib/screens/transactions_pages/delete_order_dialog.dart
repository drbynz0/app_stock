import 'package:flutter/material.dart';

class DeleteOrderDialog extends StatefulWidget {
  final String orderId;
  final Future Function() onConfirm;

  const DeleteOrderDialog({
    super.key,
    required this.orderId,
    required this.onConfirm,
  });

  @override
  State<DeleteOrderDialog> createState() => _DeleteOrderDialogState();
}

class _DeleteOrderDialogState extends State<DeleteOrderDialog> {
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    setState(() => _isDeleting = true);
    try {
      await widget.onConfirm();
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Confirmer la suppression'),
      content: _isDeleting
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Suppression de la commande #${widget.orderId}...'),
                SizedBox(height: 16),
                CircularProgressIndicator(),
              ],
            )
          : Text('Voulez-vous vraiment supprimer la commande #${widget.orderId} ?'),
      actions: _isDeleting
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: _handleDelete,
                child: Text('Supprimer', style: TextStyle(color: Colors.red)),
              ),
            ],
    );
  }
}