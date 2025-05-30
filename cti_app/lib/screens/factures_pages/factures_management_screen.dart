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
          bottom: const TabBar(
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.blue,
            tabs: [
              Tab(text: 'Commandes Internes', icon: Icon(Icons.store)),
              Tab(text: 'Commandes Externes', icon: Icon(Icons.local_shipping)),
            ],
            indicatorColor: Colors.blue,
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