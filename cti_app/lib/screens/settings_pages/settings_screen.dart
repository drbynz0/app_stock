// ignore_for_file: use_build_context_synchronously

import 'pin_code_screen.dart';
import 'package:cti_app/screens/settings_pages/about_section.dart';
import 'package:cti_app/screens/settings_pages/profile_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'change_password_screen.dart';
import 'pin_options_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final secureStorage = const FlutterSecureStorage();
  bool pinEnabled = false;
  bool fingerprintEnabled = false;
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    loadPinSetting();
  }

  Future<void> loadPinSetting() async {
    final enabled = await secureStorage.read(key: 'pin_enabled');
    setState(() {
      pinEnabled = enabled == 'true';
    });
  }

  Future<void> togglePin(bool value) async {
    if (value) {
      // Activer le PIN
      final savedPin = await secureStorage.read(key: 'user_pin');
      if (savedPin == null || savedPin.isEmpty) {
        // Pas de PIN existant, rediriger vers l'écran de création
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PinCodeScreen(isCreating: true)),
        );
        
        if (result == true) {
          setState(() {
            pinEnabled = true;
          });
          await secureStorage.write(key: 'pin_enabled', value: 'true');
        }
      } else {
        // PIN existe déjà, juste activer
        setState(() {
          pinEnabled = true;
        });
        await secureStorage.write(key: 'pin_enabled', value: 'true');
      }
    } else {
      // Désactiver le PIN (ne pas supprimer le code, juste désactiver la vérification)
      setState(() {
        pinEnabled = false;
      });
      await secureStorage.write(key: 'pin_enabled', value: 'false');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text('Paramètres'),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsSection(
            title: 'Compte',
            children: [
              _buildSettingsTile(
                icon: Icons.person,
                title: 'Profil',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                icon: notificationsEnabled
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                title: 'Notifications',
                trailing: Switch(
                  value: notificationsEnabled,
                  onChanged: (v) {
                    setState(() {
                      notificationsEnabled = v;
                    });
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            title: 'Accéssibilité',
            children: [
              SwitchListTile(
                title: const Text('Mode sombre'),
                value: theme.isDarkMode,
                onChanged: (value) => theme.toggleTheme(),
                secondary: Icon(
                  theme.isDarkMode 
                    ? Icons.nightlight 
                    : Icons.wb_sunny,
                  color: theme.iconColor,
                ),
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSecuritySection(),
          const SizedBox(height: 24),
          _buildSettingsSection(
            title: 'À propos',
            children: [
              _buildSettingsTile(
                icon: Icons.info,
                title: 'Version',
                subtitle: '1.0.0',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutSection()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text(
                'Déconnexion',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    final theme = Provider.of<ThemeProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            'Sécurité',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.titleColor,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: _buildSettingsTile(
            icon: Icons.lock,
            title: 'Changer le mot de passe',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
              );
            },
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(Icons.pin, color: theme.iconColor),
            title: const Text('PIN'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: pinEnabled,
                  onChanged: togglePin, // Utilise directement togglePin
                  activeColor: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PinOptionsScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    final theme = Provider.of<ThemeProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.titleColor
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Provider.of<ThemeProvider>(context);
    return ListTile(
      leading: Icon(icon, color: theme.iconColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}