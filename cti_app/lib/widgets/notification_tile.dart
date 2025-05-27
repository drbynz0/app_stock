import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: notification.read 
              ? Colors.grey.shade300 
              // ignore: deprecated_member_use
              : const Color(0xFF003366).withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getIconForType(notification.type),
          color: _getColorForType(notification.type),
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.read ? FontWeight.normal : FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.message),
          const SizedBox(height: 4),
          Text(
            notification.formattedDate,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey),
          ),
        ],
      ),
      trailing: notification.read
          ? null
          : Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
    );
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Icons.shopping_cart;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.system:
        return Icons.notifications;
      case NotificationType.promotion:
        return Icons.local_offer;
    }
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Colors.blue.shade800;
      case NotificationType.payment:
        return Colors.green.shade800;
      case NotificationType.system:
        return Colors.orange.shade800;
      case NotificationType.promotion:
        return Colors.purple.shade800;
    }
  }
}