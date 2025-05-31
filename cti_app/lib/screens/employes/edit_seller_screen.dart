// ignore_for_file: use_build_context_synchronously

import 'package:cti_app/constants/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:cti_app/controller/user_controller.dart';

class EditEmployeDialog extends StatefulWidget {
  final Map<String, dynamic> employee;
  final VoidCallback onEmployeeUpdated;

  const EditEmployeDialog({
    super.key,
    required this.employee,
    required this.onEmployeeUpdated,
  });

  @override
  State<EditEmployeDialog> createState() => _EditEmployeDialogState();
}

class _EditEmployeDialogState extends State<EditEmployeDialog> {
  late final TextEditingController _usernameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late String _privilege;
  bool _isLoading = false;
  final primaryColor = Colors.blue.shade800;
  final textColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.employee['username']);
    _firstNameController = TextEditingController(text: widget.employee['first_name']);
    _lastNameController = TextEditingController(text: widget.employee['last_name']);
    _emailController = TextEditingController(text: widget.employee['email']);
    _phoneController = TextEditingController(text: widget.employee['phone'] ?? '');
    _privilege = widget.employee['user_type'];
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
          final updatedData = {
            'username': _usernameController.text,
            'first_name': _firstNameController.text,
            'last_name': _lastNameController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
            'user_type': _privilege,
          };
      await UserController.updateUser(
        widget.employee['id'],
        updatedData,
      );
      widget.onEmployeeUpdated();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Modifier employé',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppConstant.PRIMARY_COLOR,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppConstant.PRIMARY_COLOR),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Nom d\'utilisateur',
                labelStyle: TextStyle(color: AppConstant.PRIMARY_COLOR),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppConstant.PRIMARY_COLOR),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppConstant.PRIMARY_COLOR, width: 2),
                ),
                prefixIcon: Icon(Icons.person, color: AppConstant.PRIMARY_COLOR),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'Prénom',
                labelStyle: TextStyle(color: AppConstant.PRIMARY_COLOR),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppConstant.PRIMARY_COLOR),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppConstant.PRIMARY_COLOR, width: 2),
                ),
                prefixIcon: Icon(Icons.person, color: AppConstant.PRIMARY_COLOR),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Nom',
                labelStyle: TextStyle(color: AppConstant.PRIMARY_COLOR),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppConstant.PRIMARY_COLOR),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppConstant.PRIMARY_COLOR, width: 2),
                ),
                prefixIcon: Icon(Icons.person_outline, color: AppConstant.PRIMARY_COLOR),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: AppConstant.PRIMARY_COLOR),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppConstant.PRIMARY_COLOR),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppConstant.PRIMARY_COLOR, width: 2),
                ),
                prefixIcon: Icon(Icons.email, color: AppConstant.PRIMARY_COLOR),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Téléphone',
                labelStyle: TextStyle(color: AppConstant.PRIMARY_COLOR),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppConstant.PRIMARY_COLOR),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppConstant.PRIMARY_COLOR, width: 2),
                ),
                prefixIcon: Icon(Icons.phone, color: AppConstant.PRIMARY_COLOR),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _privilege,
              decoration: InputDecoration(
                labelText: 'Rôle',
                labelStyle: TextStyle(color: AppConstant.PRIMARY_COLOR),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppConstant.PRIMARY_COLOR),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppConstant.PRIMARY_COLOR, width: 2),
                ),
                prefixIcon: Icon(Icons.work, color: AppConstant.PRIMARY_COLOR),
              ),
              dropdownColor: Colors.white,
              style: TextStyle(color: Colors.black),
              items: ['ADMIN', 'SELLER']
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _privilege = value!),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstant.PRIMARY_COLOR,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? CircularProgressIndicator(color: textColor)
                    : Text(
                        'ENREGISTRER',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}