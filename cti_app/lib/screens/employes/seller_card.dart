// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:cti_app/controller/user_controller.dart';
import 'package:cti_app/screens/employes/edit_seller_screen.dart';
import 'package:cti_app/screens/employes/sellers_details_screen.dart';
import 'package:flutter/material.dart';

class EmployeCard extends StatelessWidget {
  final dynamic employee;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const EmployeCard({
    super.key,
    required this.employee,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final isSeller = employee['user_type'] == 'SELLER';
    final color = isSeller ? const Color.fromARGB(255, 4, 90, 160) : Colors.deepPurple;

    return Card(
      color: const Color.fromARGB(255, 194, 224, 240),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isSeller 
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SellerDetailScreen(seller: employee),
                  ),
                ).then((_) {
                  onUpdate.call();
                })
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Icon(
                  isSeller ? Icons.person : Icons.admin_panel_settings,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee['username'] ?? 'Sans nom',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee['email'] ?? 'Pas d\'email',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Chip(
                      label: Text(employee['user_type']),
                      backgroundColor: color.withOpacity(0.1),
                      labelStyle: TextStyle(color: color),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Modifier'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Supprimer', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'edit') {
                    showDialog(
                      context: context,
                      builder: (context) => EditEmployeDialog(
                        employee: employee,
                        onEmployeeUpdated: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Employé modifié avec succès'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          onUpdate();
                        },
                      ),
                    );
                  } else if (value == 'delete') {
                    _confirmDelete(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer cet employé ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await UserController.deleteUser(employee['id']);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Employé supprimé'),
                    backgroundColor: Colors.red,
                  ),
                );
                onDelete();
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}