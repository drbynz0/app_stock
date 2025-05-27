import 'package:flutter/material.dart';
import '/models/notification_model.dart';
import '/widgets/notification_tile.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white), // Texte en blanc
        ),
        iconTheme: const IconThemeData(color: Colors.white), // Flèche en blanc
        backgroundColor: const Color(0xFF003366),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
       
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: demoNotifications.length,
        separatorBuilder: (context, index) => const Divider(height: 16),
        itemBuilder: (context, index) {
          final notification = demoNotifications[index];
          return NotificationTile(
            notification: notification,
            onTap: () => _handleNotificationTap(context, notification),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, NotificationModel notification) {
    // Navigation ou action spécifique selon le type de notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Action: ${notification.title}')),
    );
  }
}