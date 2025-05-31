import 'package:cti_app/services/app_data_service.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/category.dart';

Future<void> showEditCategorieDialog(
  BuildContext context,
  Category categorie,
  VoidCallback onSuccess,
) async {
  final TextEditingController nameController = TextEditingController(text: categorie.name);
  final TextEditingController descController = TextEditingController(text: categorie.description);
  final formKey = GlobalKey<FormState>();
  final theme = Provider.of<ThemeProvider>(context, listen: false);

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // En-tête avec icône
              Row(
                children: [
                  Icon(Icons.edit_note, size: 32, color: Colors.blue.shade700),
                  const SizedBox(width: 10),
                  Text(
                    'Modifier la catégorie',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.titleColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Champ Nom
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  prefixIcon: Icon(Icons.label, color: theme.iconColor),
                  filled: true,
                ),
                validator: (value) => value!.isEmpty ? 'Ce champ est obligatoire' : null,
              ),
              const SizedBox(height: 15),

              // Champ Description
              TextFormField(
                controller: descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  filled: true,
                ),
              ),
              const SizedBox(height: 25),

              // Boutons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                    child: Text(
                      'Annuler',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save, size: 20),
                    label: const Text('Enregistrer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.buttonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue.shade600,
                          ),
                        ),
                      );

                      try {
                        final updatedCategorie = Category(
                          id: categorie.id,
                          name: nameController.text.trim(),
                          description: descController.text.trim(),
                        );
                        
                        final appData = Provider.of<AppData>(context, listen: false);

                        appData.updateCategory(updatedCategorie);
                        
                        if (context.mounted) {
                          Navigator.pop(context); // Fermer le loader
                          Navigator.pop(context); // Fermer la boîte de dialogue

                          onSuccess();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Catégorie "${updatedCategorie.name}" mise à jour'),
                              backgroundColor: Colors.green.shade600,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur: ${e.toString()}'),
                              backgroundColor: Colors.red.shade600,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}