// user_controller.dart
import 'dart:convert';
import 'package:cti_app/constants/app_constant.dart';
import 'package:cti_app/services/api_service.dart';
import 'package:http/http.dart' as http;

class UserController {
  static const String baseUrl = AppConstant.BASE_URL + AppConstant.SELLER_URI;
  static Map<String, bool> myPrivileges = {};

  static Future<List<dynamic>> getAllUsers() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: await ApiService.headers(),
      );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des utilisateurs: ${response.body}');
    }
  }

  static Future<bool> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('${baseUrl}delete/$id/'),
      headers: await ApiService.headers(),
    );
    if (response.statusCode == 204) {
      return response.statusCode == 204;
    } else {
      throw Exception('Erreur lors de la suppression de l\'utilisateur: ${response.body}');
    }
  }

static Future<bool> addUser(String name, String email, String password, String? phone, String role) async {
  final response = await http.post(
    Uri.parse('${baseUrl}create/'),
    headers: await ApiService.headers(),
    body: jsonEncode({
      'username': name,
      'email': email,
      'password': password,
      'user_type': role,
      'phone': phone,
    }),
  );
  if (response.statusCode == 201) {
    return response.statusCode == 201;
  } else {
    throw Exception('Erreur lors de l\'ajout de l\'utilisateur: ${response.body}');
  }
}


  static Future<bool> updateUser(int id, String name, String email, String role) async {
    final response = await http.patch(
      Uri.parse('${baseUrl}update/$id/'),
      headers: await ApiService.headers(),
      body: jsonEncode({
        'username': name,
        'email': email,
        'type_user': role,
      }),
    );
    if (response.statusCode == 200) {
    return response.statusCode == 200;
    } else {
      throw Exception('Erreur lors de la mise à jour de l\'utilisateur: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> fetchUserProfile() async {
    final response = await http.get(
      Uri.parse('${AppConstant.BASE_URL}profile/'),
      headers: await ApiService.headers(),
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData;
    } else {
      throw Exception('Erreur lors de la récupération du profil utilisateur : ${response.body}');
    }
  }

  static Future<Map<String, dynamic>>? fetchUserPrivileges() async {
    final response = await http.get(
      Uri.parse('${AppConstant.BASE_URL}profile/'),
      headers: await ApiService.headers(),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['privileges'] != null) {
          return responseData['privileges'];
        } else {
          return {};
        }

      } else {
        throw Exception('Erreur lors de la récupération des privilèges de l\'utilisateur : ${response.body}');
      }
  }

  static Future<bool> updateUserPrivileges(int userId, Map<String, bool> privileges) async {
    final response = await http.patch(
      Uri.parse('${baseUrl}update/$userId/'),
      headers: await ApiService.headers(),
      body: jsonEncode({
        'privileges': privileges,
      }),
    );
    if (response.statusCode == 200) {
      return response.statusCode == 200;
      } else {
        throw Exception('Erreur lors de la mise à jour des privilèges de l\'utilutilisateur : ${response.body}');
      }
  }

}
