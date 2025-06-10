// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'pin_code_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class PinOptionsScreen extends StatelessWidget {
  const PinOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final secureStorage = const FlutterSecureStorage();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Options PIN', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.add_box),
                title: const Text('Créer un code PIN'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final savedPin = await secureStorage.read(key: 'user_pin');
                  if (savedPin != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Code PIN déjà créé"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PinCodeScreen(isCreating: true)),
                    );
                  
                    if (result == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Code PIN créé avec succès")),
                      );
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.edit),
                title: const Text('Changer le code PIN'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  // Vérifier d'abord le PIN actuel
                  final verified = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PinCodeScreen(isCreating: false)),
                  );

                  if (verified == true) {
                    // Si vérification réussie, créer un nouveau PIN
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PinCodeScreen(isCreating: true)),
                    );

                    if (result == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Code PIN changé avec succès"),
                          backgroundColor: Colors.green,
                          ),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}