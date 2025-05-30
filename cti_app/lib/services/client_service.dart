// ignore_for_file: avoid_print

import 'package:cti_app/controller/customer_controller.dart';
import 'package:cti_app/models/client.dart';
import 'package:flutter/material.dart';

class ClientService extends ChangeNotifier {
  final List<Client> _clients = [];

  List<Client> get clientList {
  final sortedClients = List<Client>.from(_clients);
  sortedClients.sort((a, b) => b.name.compareTo(a.name));
  return List.unmodifiable(sortedClients);
  }

  
  Future<void> fetchClients() async {
    try {
      final clients = await CustomerController.getCustomers();
      _clients.clear();
      _clients.addAll(clients);
      print('Clients chargées avec succès !');
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des clients: $e');
    }
  }

  void addClient(Client client) async {
    try {
        final createdClient = await CustomerController.createCustomer(client);
        _clients.insert(0, createdClient);
        print('Client ajoutée !');
        await fetchClients();
        notifyListeners();
      } catch (e) {
        print('Erreur: $e');
      }
    notifyListeners();
  }

  Future<void> deleteClient(Client client) async {
    try {
      await CustomerController.deleteCustomer(client.id!);
      _clients.removeWhere((c) => c.id == client.id);
      print('Client supprimée !');
      await fetchClients();
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la suppression du client: $e');
    }
  }
}


