import 'dart:convert';
import 'package:cti_app/constants/app_constant.dart';
import 'package:cti_app/models/client.dart';
import 'package:cti_app/services/api_service.dart';
import 'package:http/http.dart' as http;

class CustomerController {
  static const String _baseUrl = AppConstant.BASE_URL + AppConstant.CUSTOMER_URI;

  // Récupérer tous les clients
  static Future<List<Client>> getCustomers() async {
    try {
      final response = await http.get(Uri.parse(
        '${_baseUrl}list/'),
        headers: await ApiService.headers(),
        );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Client.fromJson(json)).toList();
      } else {
        throw Exception('Échec du chargement des clients: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Récupérer un client par ID
  static Future<Client> getCustomerById(int id) async {
    try {
      final response = await http.get(Uri.parse(
        '$_baseUrl/customers/$id/'),
        headers: await ApiService.headers(),
        );
      
      if (response.statusCode == 200) {
        return Client.fromJson(json.decode(response.body));
      } else {
        throw Exception('Client non trouvé');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Ajouter un nouveau client
  static Future<Client> createCustomer(Client client) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}list/'),
        headers: await ApiService.headers(),
        body: json.encode({
          'name': client.name,
          'email': client.email,
          'phone_number': client.phone,
          'address': client.address,
          'ice': client.ice,
          'is_company': client.isCompagny,
        }),
      );

      if (response.statusCode == 201) {
        return Client.fromJson(json.decode(response.body));
      } else {
        throw Exception('Échec de la création du client: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Mettre à jour un client
  static Future<Client> updateCustomer(Client client) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl${client.id}/'),
        headers: await ApiService.headers(),
        body: json.encode({
          'name': client.name,
          'email': client.email,
          'phone_number': client.phone,
          'address': client.address,
          'ice': client.ice,
          'is_company': client.isCompagny,
        }),
      );

      if (response.statusCode == 200) {
        return Client.fromJson(json.decode(response.body));
      } else {
        throw Exception('Échec de la mise à jour du client');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Supprimer un client
  static Future<void> deleteCustomer(int id) async {
    try {
      final response = await http.delete(Uri.parse(
        '$_baseUrl$id/'),
        headers: await ApiService.headers(),
        );
      
      if (response.statusCode != 204) {
        throw Exception('Échec de la suppression du client');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }
}