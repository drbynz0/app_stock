// ignore_for_file: use_build_context_synchronously

import 'package:cti_app/controller/customer_controller.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/client.dart';
import 'add_client_screen.dart';
import 'edit_client_screen.dart';
import 'delete_client_screen.dart';
import 'client_details_screen.dart';

class ClientManagementScreen extends StatefulWidget {
  const ClientManagementScreen({super.key});

  @override
  State<ClientManagementScreen> createState() => _ClientManagementScreenState();
}

class _ClientManagementScreenState extends State<ClientManagementScreen> {
  List<Client> _clients = [];

  String _searchQuery = '';
  int _currentPage = 1;
  final int _itemsPerPage = 5;

    @override
  void initState() {
    super.initState();
    _refreshOption();
  }

  // Méthode pour rafraîchir
  Future<void> _refreshOption() async {
    final updatedClients = await CustomerController.getCustomers();
    setState(() {
      _clients = updatedClients;
    });
  }

  List<Client> get filteredClients {
    return _clients.where((client) {
      return client.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Client> get paginatedClients {
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;
    endIndex = endIndex > filteredClients.length ? filteredClients.length : endIndex;
    return filteredClients.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Barre de recherche
                Container(
                  decoration: BoxDecoration(
                    color: theme.searchBar,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: theme.shadowColor,
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher un client...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _currentPage = 1;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Liste des clients
                Expanded(
                  child: ListView.builder(
                    itemCount: paginatedClients.length,
                    itemBuilder: (context, index) {
                      final client = paginatedClients[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClientDetailsScreen(client: client, internalOrders: [],),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                // Badge avec les initiales du client
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: const Color(0xFF004A99),
                                  child: Text(
                                    client.name[0],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Informations du client
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        client.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: theme.nameColor
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        client.email,
                                        style: TextStyle(color: theme.secondaryTextColor, fontSize: 13),
                                      ),
                                      Text(
                                        client.phone,
                                        style: TextStyle(color: theme.secondaryTextColor, fontSize: 13),
                                      ),
                                      Text(
                                        client.address,
                                        style: TextStyle(color: theme.secondaryTextColor, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                // Boutons d'action
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      tooltip: 'Modifier',
                                      onPressed: () => _showEditClientDialog(client),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Supprimer',
                                      onPressed: () => {
                                        _showDeleteDialog(client),
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Pagination
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredClients.length} éléments',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Row(
                        children: [
                          Text(
                            'Page $_currentPage/${(filteredClients.length / _itemsPerPage).ceil()}',
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: _currentPage > 1
                                ? () => setState(() => _currentPage--)
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: _currentPage < (filteredClients.length / _itemsPerPage).ceil()
                                ? () => setState(() => _currentPage++)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bouton flottant positionné manuellement
          Positioned(
            bottom: 65,
            right: 15, // Changez ces valeurs pour personnaliser la position
            child: FloatingActionButton(
              onPressed: _showAddClientDialog,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddClientDialog() {
    showDialog(
      context: context,
      builder: (context) => AddClientScreen(
        onAddClient: (newClient) async {
          await _refreshOption();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${newClient.name} est Ajouté avec succès'), duration: const Duration(seconds: 3), backgroundColor: Colors.green,),
          );
          Navigator.pop(context);
        },
      ),
    );
  }

    void _showEditClientDialog(Client client) {
    showDialog(
      context: context,
      builder: (context) => EditClientScreen(
        client: client,
        onEditClient: (updateClient) async {
          await _refreshOption();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${client.name} est Modifié avec succès'), backgroundColor: Colors.green,),
          );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDeleteDialog(Client client) {
    showDialog(
      context: context,
      builder: (context) =>  DeleteClientScreen(
        client: client,
        onDeleteClient: () async {
          await CustomerController.deleteCustomer(client.id!);
          await _refreshOption();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${client.name} est supprimé avec succès'), duration: const Duration(seconds: 3), backgroundColor: Colors.red,),
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}