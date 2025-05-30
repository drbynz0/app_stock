// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo et version
            Hero(
              tag: 'app-logo',
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: isDarkMode ? Colors.blueGrey[800] : Colors.blue[50],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.apps,
                  size: 60,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Mon Application',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),

            // Section informations
            _buildInfoCard(
              context,
              title: 'Développement',
              items: [
                _buildInfoItem(
                  icon: Icons.code,
                  label: 'Développeur',
                  description: 'Votre Société',
                ),
                _buildInfoItem(
                  icon: Icons.update,
                  label: 'Dernière mise à jour',
                  description: '15/06/2023',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section légale
            _buildInfoCard(
              context,
              title: 'Notre Application',
              items: [
                _buildInfoItem(
                  icon: Icons.rocket_launch,
                  label: 'Mission',
                  description: 'Simplifier la gestion commerciale pour les PME',
                ),
                _buildInfoItem(
                  icon: Icons.star,
                  label: 'Avantages clés',
                  description: 'Gestion intégrée des stocks, clients et ventes',
                ),
                _buildInfoItem(
                  icon: Icons.group,
                  label: 'Pour qui ?',
                  description: 'Commerçants, artisans et petites entreprises',
                ),
                _buildInfoItem(
                  icon: Icons.bolt,
                  label: 'Fonctionnalités principales',
                  onTap: () => _showFeaturesDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Bouton de retour
            FilledButton.tonal(
              onPressed: () => Navigator.pop(context),
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...items,
          ],
        ),
      ),
    );
  }

Widget _buildInfoItem({
  required IconData icon,
  required String label,
  String? description,
  int maxLines = 1,
  bool isExpandable = false,
  VoidCallback? onTap,
}) {

  return InkWell(
    borderRadius: BorderRadius.circular(8),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (isExpandable) 
            Icon(
              Icons.chevron_right,
            ),
        ],
      ),
    ),
  );
}

  void _showFeaturesDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Fonctionnalités Clés'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFeatureItem(Icons.inventory, 'Gestion des stocks en temps réel'),
            _buildFeatureItem(Icons.people, 'Suivi complet des clients'),
            _buildFeatureItem(Icons.receipt, 'Facturation professionnelle'),
            _buildFeatureItem(Icons.analytics, 'Tableaux de bord analytiques'),
            _buildFeatureItem(Icons.cloud, 'Synchronisation cloud sécurisée'),
            _buildFeatureItem(Icons.mobile_friendly, 'Application mobile optimisée'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        ),
      ],
    ),
  );
}

Widget _buildFeatureItem(IconData icon, String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 16),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

}