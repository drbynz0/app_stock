import 'package:cti_app/services/app_data_service.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/category.dart';

Future<void> showAddCategorieDialog(
  BuildContext context,
  VoidCallback onSuccess,
) async {
    final theme = Provider.of<ThemeProvider>(context , listen: false);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final formKey = GlobalKey<FormState>();

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
          color: theme.dialogColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // En-tête avec icône
                Row(
                  children: [
                    Icon(Icons.add_circle, size: 32, color: theme.iconColor,
),
                    const SizedBox(width: 10),
                    Text(
                      'Nouvelle Catégorie',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.titleColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Champ Nom
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom*',
                    labelStyle: TextStyle(color: theme.textColor),
                    hintText: 'Saisissez le nom de la catégorie',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
                    ),
                    filled: true,
                  ),
                  validator: (value) => value!.isEmpty ? 'Le nom est obligatoire' : null,
                ),
                const SizedBox(height: 15),

                // Champ Description
                TextFormField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: theme.textColor),
                    hintText: 'Description optionnelle',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
                    ),
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
                          color: theme.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_task, size: 20),
                      label: const Text('Créer'),
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
                              color: Colors.blue.shade800,
                            ),
                          ),
                        );

                        try {
                          final newCategorie = Category(
                            id: 0,
                            name: nameController.text.trim(),
                            description: descController.text.trim(),
                          );

                          final appData = Provider.of<AppData>(context, listen: false);
                          final _ = appData.addCategory(newCategorie);

                          if (context.mounted) {
                            Navigator.pop(context); // Fermer le loader
                            Navigator.pop(context); // Fermer la boîte de dialogue
                            onSuccess();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Catégorie "${newCategorie.name}" créée', style: TextStyle(color: Colors.white)),
                                backgroundColor: Colors.green.shade600,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
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
    ),
  );
}