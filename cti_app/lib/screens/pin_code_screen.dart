// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinCodeScreen extends StatefulWidget {
  final bool isCreating;
  const PinCodeScreen({super.key, this.isCreating = false});

  @override
  State<PinCodeScreen> createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen> {
  final _storage = const FlutterSecureStorage();
  String pin = "";

  void _addDigit(String digit) async {
      if (pin.length < 4) {
        setState(() {
          pin += digit;
        });

        if (pin.length == 4) {
          if (widget.isCreating) {
            await _storage.write(key: 'user_pin', value: pin);
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Code PIN enregistré")),
            );
            // ignore: use_build_context_synchronously
            Navigator.pop(context, true);
          } else {
            final savedPin = await _storage.read(key: 'user_pin');
            if (pin == savedPin) {
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushReplacementNamed('/home');
            } else {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Code PIN incorrect")),
              );
              setState(() {
                pin = "";
              });
            }
          }
        }
      }
  }

  void _deleteDigit() {
    if (pin.isNotEmpty) {
      setState(() {
        pin = pin.substring(0, pin.length - 1);
      });
    }
  }

  void _cancel() {
    Navigator.pop(context, false);
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: index < pin.length ? const Color(0xFF004A99) : Colors.transparent,
            border: Border.all(color: const Color(0xFF004A99)),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }

  Widget _buildKeyboardButton(String label, {VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(8),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF003366),
          ),
        ),
      ),
    );
  }
  Widget _buildKeyboard() {
    return SizedBox(
      height: 350, // Ajuste la hauteur selon tes besoins
      child: Stack(
        children: [
          Column(
            children: [
              for (var row in [
                ['1', '2', '3'],
                ['4', '5', '6'],
                ['7', '8', '9'],
              ])
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row
                      .map((digit) => _buildKeyboardButton(digit, onPressed: () => _addDigit(digit)))
                      .toList(),
                ),
              const SizedBox(height: 70), // Laisse de la place pour le Row positionné
            ],
          ),
          Positioned(
            left: 0,
            right: 40,
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: _cancel,
                  child: Text(
                    "Annuler",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF004A99),
                    ),
                  ),
                ),
                _buildKeyboardButton("0", onPressed: () => _addDigit("0")),
                IconButton(
                  onPressed: _deleteDigit,
                  icon: const Icon(Icons.backspace, color: Color(0xFF004A99)),
                  iconSize: 28,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: Text(widget.isCreating ? "Créer PIN" : "Entrer PIN",
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF003366),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: !widget.isCreating,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.isCreating ? "Créer un code PIN" : "Entrer le code PIN",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF003366),
            ),
          ),
          const SizedBox(height: 20),
          _buildPinDots(),
          const SizedBox(height: 40),
          _buildKeyboard(),
        ],
      ),
    );
  }
}
