// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:cti_app/constants/app_constant.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ChatAssistantScreen extends StatefulWidget {
  const ChatAssistantScreen({super.key});

  @override
  State<ChatAssistantScreen> createState() => _ChatAssistantScreenState();
}

class _ChatAssistantScreenState extends State<ChatAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = []; // {'role': 'user' | 'bot', 'message': ...}

  void _sendMessage(String message) async {
    final baseUrl = AppConstant.BASE_URL;
   final response = await http.post(
    Uri.parse("${baseUrl}ask-ai/"),
    headers: {"Content-Type": "application/json"},
      body: jsonEncode({"question": message}),
    );
   final data = jsonDecode(response.body);
   if (data['success']) {
     print("Result: \${data['result']}");
   } else {
      print("Error: \${data['error']}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Assistant IA')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color: isUser ? theme.primaryColor : theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['message'] ?? '',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Pose ta question...'),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
