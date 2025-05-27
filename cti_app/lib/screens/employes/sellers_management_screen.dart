// ignore_for_file: use_build_context_synchronously

import 'package:cti_app/constants/app_constant.dart';
import 'package:cti_app/screens/employes/seller_card.dart';
import 'package:flutter/material.dart';
import 'package:cti_app/controller/user_controller.dart';
import 'package:cti_app/screens/employes/add_seller_screen.dart';
//import 'package:cti_app/screens/employes/components/employe_card.dart';

class EmployeScreen extends StatefulWidget {
  const EmployeScreen({super.key});

  @override
  State<EmployeScreen> createState() => _EmployeScreenState();
}

class _EmployeScreenState extends State<EmployeScreen> {
  List<dynamic> employees = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _fetchEmployees() async {
    setState(() => isLoading = true);
    try {
      final data = await UserController.getAllUsers();
      setState(() => employees = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<dynamic> get _filteredEmployees {
    if (searchQuery.isEmpty) return employees;
    return employees.where((emp) => 
      emp['username'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
      emp['email'].toString().toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppConstant.APPBAR_COLOR,
        title: const Text('Gestion des Employés', style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchEmployees,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Rechercher un employé...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: (value) => setState(() => searchQuery = value),
                    ),
                  ),
                  Expanded(
                    child: _filteredEmployees.isEmpty
                      ? const Center(child: Text('Aucun employé trouvé'))
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8),
                          itemCount: _filteredEmployees.length,
                          itemBuilder: (context, index) => EmployeCard(
                            employee: _filteredEmployees[index],
                            onDelete: _fetchEmployees,
                            onUpdate: _fetchEmployees,
                          ),
                        ),
                  )
                ]

              )

            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => (
          showDialog(
            context: context,
            builder: (context) => AddEmployeDialog(
              onEmployeeAdded: () {
                // Rafraîchir la liste des employés après ajout
                _fetchEmployees();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Employé ajouté avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ),
        ),
        label: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue,
      ),
    );
  }
}