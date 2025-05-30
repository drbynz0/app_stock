import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:connectivity_plus/connectivity_plus.dart';
import '/services/network_service.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  
  const ConnectivityWrapper({super.key, required this.child});

  @override
  ConnectivityWrapperState createState() => ConnectivityWrapperState();
}

class ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    NetworkService.connectivityStream.listen((result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
      if (!_isConnected) {
        _showNoInternetDialog();
      }
    });
  }

  Future<void> _checkConnection() async {
    final isConnected = await NetworkService.hasInternetConnection();
    setState(() {
      _isConnected = isConnected;
    });
    if (!isConnected) {
      _showNoInternetDialog();
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Pas de connexion Internet'),
        content: const Text('Veuillez vérifier votre connexion Internet et réessayer.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkConnection(); // Re-vérifier la connexion
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}