import 'package:flutter/material.dart';
import 'factures_internal_screen.dart';
import 'factures_external_screen.dart';

class FacturesManagementScreen extends StatelessWidget {
  const FacturesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestion des Factures', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: const Color(0xFF003366),
          bottom: const TabBar(
            unselectedLabelColor: Color.fromARGB(179, 132, 134, 134),
            labelColor: Color.fromARGB(255, 170, 225, 243),
            tabs: [
              Tab(text: 'Commandes Internes', icon: Icon(Icons.store)),
              Tab(text: 'Commandes Externes', icon: Icon(Icons.local_shipping)),
            ],
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        body: const TabBarView(
          children: [
            FacturesInternalScreen(),
            FacturesExternalScreen(),
          ],
        ),
      ),
    );
  }
}