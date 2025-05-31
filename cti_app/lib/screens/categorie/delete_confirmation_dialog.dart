// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:cti_app/services/app_data_service.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/category.dart';

Future<void> showDeleteConfirmationDialog(
  BuildContext context,
  Category category,  // Renommé de 'categorie' à 'category' pour la cohérence
  VoidCallback onDeleted,
) async {
  final theme = Provider.of<ThemeProvider>(context, listen: false);
  return showDialog(
    context: context,
    barrierDismissible: false,  // Empêche la fermeture en cliquant à l'extérieur
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: BorderRadius.circular(20),
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
                'Supprimer la catégorie ?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.titleColor,
                ),
              ),
              const SizedBox(height: 16),

              // Détails de la catégorie
              _buildDetailRow('Nom', category.name),
              _buildDetailRow('Description', category.description ?? 'Aucune'),
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
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Bouton Supprimer
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          // Ajout d'un indicateur de chargement
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(child: CircularProgressIndicator()),
                          );

                          final appData = Provider.of<AppData>(context, listen: false);

                          appData.deleteCategory(category.id!);
                          
                          Navigator.pop(context);
                          Navigator.pop(context);

                          onDeleted();    
                          // Feedback visuel
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Catégorie "${category.name}" supprimée', style: TextStyle(color: Colors.white)),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur lors de la suppression: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            'Supprimer',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        );
    },
  );
}

Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
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