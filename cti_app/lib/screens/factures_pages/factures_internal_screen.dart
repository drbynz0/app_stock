import 'package:cti_app/models/client.dart';
import 'package:cti_app/services/app_data_service.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/factures.dart';
import '/models/internal_order.dart';
import 'details_facture_internal_screen.dart'; // Importez votre écran de détail

class FacturesInternalScreen extends StatefulWidget {
  const FacturesInternalScreen({super.key});

  @override
  FacturesInternalScreenState createState() => FacturesInternalScreenState();
}

class FacturesInternalScreenState extends State<FacturesInternalScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<FactureClient> internalFactures = [];
  List<InternalOrder> internalOrders = []; // Vous devez récupérer cette liste
  List<Client> clients = []; // Vous devez récupérer cette liste

  @override
  void initState() {
    super.initState();
    _refreshOption();
  }

  // Méthode pour rafraîchir
  Future<void> _refreshOption() async {
    final appData = Provider.of<AppData>(context, listen: false);
    final availableFactures = appData.facturesClient;
    final availableInternalOrders = appData.internalOrders;
    final availableClients = appData.clients;
    setState(() {
      internalFactures = availableFactures;
      internalOrders = availableInternalOrders;
      clients = availableClients;
    });
  }

  List<FactureClient> _filterFactures(List<FactureClient> factures) {
    return factures.where((facture) {
      return facture.clientName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFactures = _filterFactures(internalFactures);
    final theme = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Rechercher par nom du client',
              labelStyle: TextStyle(color: theme.textColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filteredFactures.length,
              itemBuilder: (context, index) {
                final facture = filteredFactures[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(facture.clientName, style: TextStyle(color: theme.nameColor)),
                    subtitle: Text('Montant: ${facture.amount.toStringAsFixed(2)} DH', style: TextStyle(color: theme.secondaryTextColor)),
                    trailing: Text(facture.date, style: TextStyle(color: theme.secondaryTextColor)),
                    onTap: () => _showFactureDetails(facture),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFactureDetails(FactureClient facture) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InternalFactureDetailScreen(
          facture: facture,
          internalOrders: internalOrders,
          clients: clients,
        ),
      ),
    );
  }
}