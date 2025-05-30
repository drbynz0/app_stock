// ignore_for_file: deprecated_member_use

import 'package:cti_app/screens/settings_pages/edit_profile.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/controller/user_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  String lastLogin = '';

  @override
  void initState() {
    super.initState();
    _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    final prefs = await SharedPreferences.getInstance();
    lastLogin = prefs.getString('last_login') ?? '';
    final updatedProfile = await UserController.fetchUserProfile();
    setState(() {
      _profile = updatedProfile;
      _isLoading = false;
    });
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    final theme = Provider.of<ThemeProvider>(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue.shade700),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, 
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshProfile,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 220,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text('Mon Profil', style: TextStyle(color: Colors.white)),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF003366),
                              Colors.blue.shade700,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Hero(
                            tag: 'profile-avatar',
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: ClipOval(
                                child: Image.asset(
                                  './assets/image/icon_app.jpg',
                                  fit: BoxFit.cover,
                                  width: 96,
                                  height: 96,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            '${_profile!['first_name']} ${_profile!['last_name']}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.titleColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '@${_profile!['username']}',
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildInfoCard(
                            'Email', 
                            _profile!['email'], 
                            Icons.email,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            'Téléphone', 
                            _profile!['phone'] ?? 'Non renseigné', 
                            Icons.phone,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            'Rôle', 
                            _profile!['user_type'] ?? 'Non spécifié', 
                            Icons.work,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            'Date de création', 
                            _formatDate(DateTime.parse(_profile!['date_joined'])), 
                            Icons.calendar_today,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoCard(
                            'Dernière connexion', 
                            _formatDate(DateTime.parse(lastLogin)), 
                            Icons.access_time,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                          onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => EditProfileDialog(
                                  currentProfile: _profile!,
                                  onProfileUpdated: (updatedProfile) {
                                    _refreshProfile();
                                  },
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit, 
                              color: Colors.white,
                            ),
                            label: const Text('Modifier le profil', 
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.buttonColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    final formattedDate = '${date.day}/${date.month}/${date.year}';
    final formattedTime = '${date.hour}h${date.minute.toString().padLeft(2, '0')}';
    return '$formattedDate à $formattedTime';
  }
}