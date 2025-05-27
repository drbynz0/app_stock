import 'package:flutter/material.dart';
import 'pin_code_screen.dart';

class PinOptionsScreen extends StatelessWidget {
  const PinOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Options PIN',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF003366),
        iconTheme: const IconThemeData(color: Colors.white), // flèche en blanc
      ),
      backgroundColor: const Color(0xFFF4F7FA),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Créer un code PIN
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.add_box, color: Color(0xFF004A99)),
                title: const Text('Créer un code PIN'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PinCodeScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Changer le code PIN
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF004A99)),
                title: const Text('Changer le code PIN'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  bool isVerified = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PinCodeScreen()),
                  );

                  if (isVerified == true) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("PIN correct ! Redirection...")),
                    );

                    await Future.delayed(const Duration(seconds: 1));

                    Navigator.push(
                      // ignore: use_build_context_synchronously
                      context,
                      MaterialPageRoute(builder: (context) => const PinCodeScreen()),
                    );
                  } else {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("PIN incorrect ou annulé.")),
                    );
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
