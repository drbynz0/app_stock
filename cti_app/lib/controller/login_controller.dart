import 'dart:convert';
import 'package:cti_app/constants/app_constant.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  static const String _baseUrl = AppConstant.BASE_URL + AppConstant.LOGIN_URI; // Remplacez par votre URL
  static String? isadmin;

  Future<bool> login(String username, String password) async {

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Sauvegarde du token et des infos utilisateur
        final responseData = jsonDecode(response.body);
        await saveUserData(
          token: responseData['token'],
          userData: responseData['user'],
          isAdmin: responseData['is_admin'],
          lastLogin: DateTime.now(),
        );
        return true;
      } else {
        debugPrint('Échec de la connexion: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Erreur lors de la connexion: $e');
      return false;
    }
  }


  Future<String> saveUserData({required String token, required Map<String, dynamic> userData, required bool isAdmin, required DateTime lastLogin}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user_data', jsonEncode(userData));
    await prefs.setString('last_login', lastLogin.toIso8601String());
    final user = jsonDecode(prefs.getString('user_data') ?? 'Inconnu');
    await prefs.setBool('is_admin', isAdmin);
    return isadmin = user['user_type'];
  }

  // Méthode pour vérifier si l'utilisateur est déjà connecté
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  // Méthode pour récupérer le token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Méthode pour déconnecter l'utilisateur
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_data');
    await prefs.remove('is_admin');
  }

  // Méthode pour récupérer les données utilisateur
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }


}