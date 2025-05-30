import 'dart:convert';

import 'package:cti_app/constants/app_constant.dart';
import 'package:cti_app/models/activity.dart';
import 'package:cti_app/services/api_service.dart';
import 'package:http/http.dart' as http;

class HistoricalController {
  static const String _baseUrl = AppConstant.BASE_URL + AppConstant.HISTORICAL_URI;

  // 🔄 GET ALL
  static Future<List<Activity>> getAllHistorical() async {
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: await ApiService.headers(),
      );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Activity.fromJson(e)).toList();
    } else {
      throw Exception('Erreur lors du chargement des activités: ${response.body}');
    }
  }

  // ➕ POST
  static Future<Activity> addActivity(Activity activity) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: await ApiService.headers(),
      body: jsonEncode(activity.toJson()),
    );
    if (response.statusCode == 201) {
      return Activity.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de l’ajout de l’activité');
    }
  }

  // 🔁 PUT
  static Future<Activity> updateActivity(int id, Activity activity) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$id/'),
      headers: await ApiService.headers(),
      body: jsonEncode(activity.toJson()),
    );
    if (response.statusCode == 200) {
      return Activity.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la modification');
    }
  }

  // ❌ DELETE
  static Future<void> deleteActivity(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl$id/'),
      headers: await ApiService.headers(),
      );
    if (response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression de l’activité : ${response.body}');
    }
  }

  static Future<void> deleteAllActivities() async {
    final response = await http.delete(
      Uri.parse(_baseUrl),
      headers: await ApiService.headers(),
    );
    if (response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression de toutes les activités : ${response.body}');
    }
  }

  // 🔍 GET by ID
  static Future<Activity> getActivity(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl$id/'));
    if (response.statusCode == 200) {
      return Activity.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Activité introuvable');
    }
  }
}