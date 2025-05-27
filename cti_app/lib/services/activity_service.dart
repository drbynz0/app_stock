// ignore_for_file: avoid_print

import 'package:cti_app/controller/historical_controller.dart';
import 'package:flutter/material.dart';
import '../models/activity.dart';

class ActivityService extends ChangeNotifier {
  final List<Activity> _activities = [];

  List<Activity> get recentActivities {
    final sortedActivities = List<Activity>.from(_activities);
    sortedActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Tri du plus récent au plus ancien
    return List.unmodifiable(sortedActivities.take(3));
  }

  List<Activity> get allActivities {
  final sortedActivities = List<Activity>.from(_activities);
  sortedActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return List.unmodifiable(sortedActivities);
}

  Future<void> fetchActivities() async {
    try {
      final activities = await HistoricalController.getAllHistorical();
      _activities.clear();
      _activities.addAll(activities);
      print('Activités chargées avec succès !');
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des activités: $e');
    }
  }

  void addActivity(String description, String icon) async {
    try {
        Activity nouvelle = Activity(
          description: description,
          iconName: icon,
          timestamp: DateTime.now(),
        );

        await HistoricalController.addActivity(nouvelle);
        _activities.insert(0, nouvelle);
        print('Activité ajoutée !');
      } catch (e) {
        print('Erreur: $e');
      }
    notifyListeners();
  }
}
