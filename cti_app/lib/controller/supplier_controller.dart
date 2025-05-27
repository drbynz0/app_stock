import 'dart:convert';
import 'package:cti_app/constants/app_constant.dart';
import 'package:cti_app/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:cti_app/models/supplier.dart';

class SupplierController {
  static const String baseUrl = AppConstant.BASE_URL + AppConstant.SUPPLIER_URI;

  static Future<List<Supplier>> getSuppliers() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: await ApiService.headers(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Supplier.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load suppliers');
    }
  }

  static Future<Supplier> getSupplierById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl$id/'),
      headers: await ApiService.headers(),
    );

    if (response.statusCode == 200) {
      return Supplier.fromJson(json.decode(response.body));
    } else {
      throw Exception('Supplier not found');
    }
  }

  static Future<Supplier> addSupplier(Supplier supplier) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await ApiService.headers(),
      body: json.encode(supplier.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add supplier ${response.body}');
    } else {
      return Supplier.fromJson(json.decode(response.body));
    }
  }

  static Future<Supplier> updateSupplier(int? id, Supplier supplier) async {
    final response = await http.put(
      Uri.parse('$baseUrl$id/'),
      headers: await ApiService.headers(),
      body: json.encode(supplier.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update supplier');
    } else {
      return Supplier.fromJson(json.decode(response.body));
    }
  }

  static Future<void> deleteSupplier(int? id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$id/'),
      headers: await ApiService.headers(),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete supplier: ${response.body}');
    }
  }
}
