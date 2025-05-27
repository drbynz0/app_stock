import 'dart:convert';
import 'package:cti_app/constants/app_constant.dart';
import 'package:cti_app/services/api_service.dart';
import 'package:http/http.dart' as http;
import '../models/delivery_note.dart';

class DeliveryNoteController {
  static const String baseUrl = AppConstant.BASE_URL + AppConstant.DELIVERY_NOTE_URI;

  /// Récupérer tous les bons
  static Future<List<DeliveryNote>> fetchDeliveryNotes() async {
    final response = await http.get(Uri.parse(
      baseUrl),
      headers: await ApiService.headers(),     
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => DeliveryNote.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des bons: ${response.body}');
    }
  }

  /// Ajouter un bon
  static Future<DeliveryNote> createDeliveryNote(DeliveryNote note) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await ApiService.headers(),
      body: jsonEncode(note.toJson()),
    );

    if (response.statusCode == 201) {
      return DeliveryNote.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la création: ${response.body}');
    }
  }

  /// Modifier un bon
  static Future<DeliveryNote> updateDeliveryNote(int id, DeliveryNote note) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id/'),
      headers: await ApiService.headers(),
      body: jsonEncode(note.toJson()),
    );

    if (response.statusCode == 200) {
      return DeliveryNote.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la modification');
    }
  }

  /// Supprimer un bon
  static Future<void> deleteDeliveryNote(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id/'),
      headers: await ApiService.headers(),
    );

    if (response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression');
    }
  }

  /// Récupérer un bon par ID
  static Future<DeliveryNote> getNoteById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id/'),
      headers: await ApiService.headers(),
    );

    if (response.statusCode == 200) {
      return DeliveryNote.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la récupération');
    }
  }
}
