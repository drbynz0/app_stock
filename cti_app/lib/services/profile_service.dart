// ignore_for_file: avoid_print

import 'package:cti_app/controller/user_controller.dart';
import 'package:flutter/material.dart';

class ProfileService extends ChangeNotifier {
  Map<String, dynamic>? _availablePrivileges = {};
  Map<String, dynamic>? _userProfile = {};

  Map<String, dynamic> get availablePrivileges => _availablePrivileges!;
  Map<String, dynamic>? get userProfile => _userProfile;

  Future<void> fetchAvailablePrivileges() async {
    try {
      // Exemple de récupération depuis un fichier local JSON dans assets
      final availablePrivileges = await UserController.fetchUserPrivileges();

      _availablePrivileges!.clear();
      _availablePrivileges!.addAll(availablePrivileges!);
      print('Privilèges récupérés avec succès !');
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la récupération des privilèges : $e');
      _availablePrivileges = {};
    }
  }

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final profile = await UserController.fetchUserProfile();
      _userProfile = profile;
      notifyListeners();
      return _userProfile;
    } catch (e) {
      print('Erreur lors de la récupération du profil utilisateur : $e');
      return null;
    }
  }
  
}
