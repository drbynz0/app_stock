import 'package:flutter/material.dart';

class Activity {
  final int? id;
  final String description;
  final String iconName; // on stocke le nom de l’icône
  final DateTime timestamp;

  Activity({
    this.id,
    required this.description,
    required this.iconName,
    required this.timestamp,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      description: json['description'],
      iconName: json['icon'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'icon': iconName,
    };
  }

  IconData get icon {
    return _iconMap[iconName] ?? Icons.help_outline;
  }

  static const Map<String, IconData> _iconMap = {
    'person_add': Icons.person_add,
    'delete': Icons.delete,
    'edit': Icons.edit,
    'info': Icons.info,
    'shopping_cart': Icons.shopping_cart,
    // ajoute d’autres icônes ici
  };
}