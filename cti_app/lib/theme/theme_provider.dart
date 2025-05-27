import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  ThemeProvider() {
    _loadThemePreference();
  }

  bool get isDarkMode => _isDarkMode;

  // Couleurs dynamiques
  Color get primaryColor => _isDarkMode ? Colors.black87 : const Color(0xFF003366);
  Color get backgroundColor => _isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50;
  Color get cardColor => _isDarkMode ? Colors.grey.shade800 : const Color.fromARGB(255, 217, 248, 247);
  Color get textColor => _isDarkMode ? Colors.white : Colors.black87;
  Color get secondaryTextColor => _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
  Color get buttonColor => _isDarkMode ? Colors.blue.shade600 : Colors.blue.shade700;
  Color get iconColor => _isDarkMode ? Colors.white : Colors.blue.shade800;
  Color get shadowColor => _isDarkMode ? Colors.black54 : Colors.grey.shade300;
  Color get borderColor => _isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300;
  Color get nameColor => _isDarkMode ? Colors.white : const Color(0xFF003366);
  Color get searchBar => _isDarkMode ? Colors.grey.shade800 : Colors.white;
  Color get barNavColor => _isDarkMode ? Colors.black87 : const Color.fromARGB(255, 217, 248, 247);
  Color get titleColor => _isDarkMode ? Colors.white : const Color(0xFF003366);


  ThemeData get themeData {
    return _isDarkMode ? buildDarkTheme() : _buildLightTheme();
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor),
        // Ajoutez d'autres styles de texte si nécessaire
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      // Autres personnalisations
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: buttonColor,
        surface: cardColor,
      ),
    );
  }

  ThemeData buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
      ),
      // Autres personnalisations
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: buttonColor,
        surface: cardColor,
      ),
    );
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    
  final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }
}