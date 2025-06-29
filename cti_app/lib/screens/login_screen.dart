import 'package:cti_app/controller/login_controller.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'password_pages/forgot_pass_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();                                       
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _reduceDecoration() {
    // Fonction vide - à implémenter si nécessaire
  }

  void _resetDecoration() {
    // Fonction vide - à implémenter si nécessaire   
    //  
  }

void _login() async {
  // Vérifier d'abord si le widget est toujours monté
  if (!mounted) return;
  
  setState(() => _isLoading = true);
  String username = _usernameController.text.trim();
  String password = _passwordController.text.trim();

  if (username.isEmpty || password.isEmpty) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    _showErrorDialog('Veuillez remplir tous les champs.');
    return;
  }

  try {
    final success = await AuthController().login(username, password);
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showErrorDialog('Identifiants incorrects');
    }
  } catch (e) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    _showErrorDialog('Erreur de connexion. Veuillez réessayer.');
    debugPrint('Login error: $e');
  }
}

void _showErrorDialog(String message) {
  // Vérifier mounted avant d'utiliser le contexte
  if (!mounted) return;
  
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Erreur'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            // Utiliser le contexte de la boîte de dialogue
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400, // Largeur maximale pour le contenu
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bienvenue !',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: theme.titleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Connectez-vous pour continuer.',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                Focus(
                  onFocusChange: (hasFocus) => hasFocus ? _reduceDecoration() : _resetDecoration(),
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Nom d\'utilisateur',
                      labelStyle: TextStyle(color: theme.secondaryTextColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.borderColor),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(height: 16),
                Focus(
                  onFocusChange: (hasFocus) => hasFocus ? _reduceDecoration() : _resetDecoration(),
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      labelStyle: TextStyle(color: theme.secondaryTextColor),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.borderColor),
                      ),
                    ),
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(
                        color: theme.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(  
                  width: double.infinity,
                  child: GestureDetector( 
                    onTap: _isLoading ? null : _login,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200), 
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: theme.buttonColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Se connecter',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ), // Espacement supplémentaire en bas
              ],
            ),
          ),
        ),
      ),
    );
  }
}