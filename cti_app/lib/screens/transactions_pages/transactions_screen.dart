import 'package:flutter/material.dart';
import 'internal_orders_screen.dart';
import 'external_orders_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TabBar(
          onTap: (index) {
            setState(() {
              // Met à jour l'état si nécessaire
            });
          },
          tabs: const [
            Tab(text: 'Ventes (Clients)', icon: Icon(Icons.store)),
            Tab(text: 'Achats (Fournisseurs)', icon: Icon(Icons.local_shipping)),

          ],
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
        ),
        body: TabBarView(
          children: [
            InternalOrdersScreen(),
            ExternalOrdersScreen(),
          ],
        ),
      ),
    );
  }
}