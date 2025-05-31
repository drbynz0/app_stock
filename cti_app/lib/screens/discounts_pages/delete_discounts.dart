// ignore_for_file: use_build_context_synchronously

import 'package:cti_app/controller/discount_controller.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/discounts.dart';

class DeleteDiscountScreen extends StatelessWidget {
  final Discount discount;
  final Function(int?) onDeleteDiscount;

  const DeleteDiscountScreen({
    super.key,
    required this.discount,
    required this.onDeleteDiscount,
  });

  void _confirmDelete(BuildContext context) async {
    final discountController = DiscountController();
    bool onPromo = false;
    double pricePromo = 0;
    await DiscountController.deleteDiscount(discount.id!);
    await discountController.applyDiscountToProduct(onPromo, discount.productId, pricePromo);
    onDeleteDiscount(discount.id);
    Navigator.pop(context); // Fermer la dialog après suppression
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.dialogColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icone d'avertissement
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),

            // Titre
            Text(
              'Supprimer la promotion ?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
            ),
            const SizedBox(height: 16),

            // Détails de la promotion
            _buildDetailRow(context, 'Titre', discount.title),
            _buildDetailRow(context, 'Produit', discount.productName),
            _buildDetailRow(context, 'Prix normal', '${discount.normalPrice} MAD'),
            _buildDetailRow(context, 'Prix promo', '${discount.promotionPrice} MAD'),
            const SizedBox(height: 24),

            // Boutons d'action
            Row(
              children: [
                // Bouton Annuler
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Annuler',
                      style: TextStyle(
                        color: theme.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Bouton Supprimer
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _confirmDelete(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Supprimer',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: theme.secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}