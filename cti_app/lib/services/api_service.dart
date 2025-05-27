import 'dart:convert';

import 'package:http/http.dart' as http;
import '/controller/login_controller.dart';

class ApiService {

  //token
  // Headers communs
  static Future<Map<String, String>> headers() async {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Token ${await AuthController.getToken()}',    
    };
  }

  // Gestion des erreurs
  static dynamic processResponse(http.Response response) {
    final responseJson = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseJson;
    } else {
      throw Exception('Erreur API: ${response.statusCode} - ${responseJson['message'] ?? 'Erreur inconnue'}');
    }
  }
}