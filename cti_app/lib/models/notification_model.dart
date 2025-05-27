import 'package:intl/intl.dart';

enum NotificationType { order, payment, system, promotion }

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final bool read;
  final NotificationType type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    this.read = false,
    required this.type,
  });

  String get formattedDate => DateFormat('dd MMM yyyy - HH:mm').format(date);
}

// Données de démonstration
final List<NotificationModel> demoNotifications = [
  NotificationModel(
    id: '1',
    title: 'Nouvelle commande',
    message: 'Vous avez reçu une nouvelle commande de 1500 €',
    date: DateTime.now().subtract(const Duration(minutes: 5)),
    read: false,
    type: NotificationType.order,
  ),
  NotificationModel(
    id: '2',
    title: 'Paiement reçu',
    message: 'Le client Jean Dupont a payé sa facture #1254',
    date: DateTime.now().subtract(const Duration(hours: 2)),
    read: true,
    type: NotificationType.payment,
  ),
  NotificationModel(
    id: '3',
    title: 'Mise à jour système',
    message: 'Une nouvelle version de l\'application est disponible',
    date: DateTime.now().subtract(const Duration(days: 1)),
    read: true,
    type: NotificationType.system,
  ),
  NotificationModel(
    id: '4',
    title: 'Promotion spéciale',
    message: 'Profitez de 20% de réduction sur tous les produits ce week-end',
    date: DateTime.now().subtract(const Duration(days: 3)),
    read: false,
    type: NotificationType.promotion,
  ),
  NotificationModel(
    id: '5',
    title: 'Stock faible',
    message: 'Le produit "Ecran 24 pouces" est presque épuisé',
    date: DateTime.now().subtract(const Duration(days: 5)),
    read: false,
    type: NotificationType.system,
  ),
];