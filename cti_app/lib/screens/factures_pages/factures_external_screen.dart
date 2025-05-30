import 'package:cti_app/controller/external_orders_controller.dart';
import 'package:cti_app/controller/facture_controller.dart';
import 'package:cti_app/controller/supplier_controller.dart';
import 'package:cti_app/models/supplier.dart';
import 'package:flutter/material.dart';
import 'package:cti_app/models/external_order.dart';
import '/models/factures.dart';
import '../factures_pages/details_facture_external_screen.dart';

class FacturesExternalScreen extends StatefulWidget {
  const FacturesExternalScreen({super.key});

  @override
  FacturesExternalScreenState createState() => FacturesExternalScreenState();
}

class FacturesExternalScreenState extends State<FacturesExternalScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<FactureFournisseur> externalFactures = [];
  List<ExternalOrder> externalOrders = [];
  List<Supplier> suppliers = []; // Vous devez récupérer cette liste
  

  @override
  void initState() {
    super.initState();
    _refreshOption();
  }

  // Méthode pour rafraîchir
  Future<void> _refreshOption() async {
    final availableFactures = await FactureSupplierController.getFactures();
    final availableExternalOrders = await ExternalOrdersController.fetchOrders();
    final availableClients = await SupplierController.getSuppliers();
    setState(() {
      externalFactures = availableFactures;
      externalOrders = availableExternalOrders;
      suppliers = availableClients;
    });
  }

  List<FactureFournisseur> _filterFactures(List<FactureFournisseur> factures) {
    return factures.where((facture) {
      return facture.supplierName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFactures = _filterFactures(externalFactures);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Rechercher par nom du fournisseur',
              border: OutlineInputBorder(),
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
                    title: Text(facture.supplierName),
                    subtitle: Text('Montant: ${facture.amount.toStringAsFixed(2)} DH'),
                    trailing: Text(facture.date),
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

  void _showFactureDetails(FactureFournisseur facture) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExternalFactureDetailScreen(
          facture: facture,
          externalOrders: externalOrders,
          suppliers: suppliers,
        ),
      ),
    );
  }
}