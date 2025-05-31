// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:cti_app/constants/app_constant.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class ChatAssistantScreen extends StatefulWidget {
  const ChatAssistantScreen({super.key});

  @override
  State<ChatAssistantScreen> createState() => _ChatAssistantScreenState();
}

class _ChatAssistantScreenState extends State<ChatAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'message': message,
        'timestamp': DateTime.now(),
      });
      _controller.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final baseUrl = AppConstant.BASE_URL;
      final response = await http.post(
        Uri.parse("${baseUrl}ask-ai/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"question": message}),
      );

      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        final responseContent = {
          'human_response': data['human_response'] ?? 'Réponse non disponible',
          'has_sql': data.containsKey('generated_sql'),
          'sql_data': data.containsKey('generated_sql') ? {
            'columns': List<String>.from(data['columns'] ?? []),
            'rows': List<List<dynamic>>.from(data['data'] ?? []),
            'query': data['generated_sql'] ?? '',
          } : null,
        };

        setState(() {
          _messages.add({
            'role': 'bot',
            'message': responseContent,
            'timestamp': DateTime.now(),
          });
        });
      } else {
        setState(() {
          _messages.add({
            'role': 'bot',
            'message': {'error': data['error'] ?? 'Erreur inconnue'},
            'timestamp': DateTime.now(),
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'bot',
          'message': {'error': 'Erreur de connexion: ${e.toString()}'},
          'timestamp': DateTime.now(),
        });
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copié dans le presse-papier')),
    );
  }

  Widget _buildBotMessage(Map<String, dynamic> content) {
    final theme = Provider.of<ThemeProvider>(context);
    
    if (content.containsKey('error')) {
      return Text(
        content['error'],
        style: const TextStyle(color: Colors.red),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Réponse humaine/explication
        Text(content['human_response'] ?? ''),

        // Section SQL si présente
        if (content['has_sql'] == true && content['sql_data'] != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Résultats de la requête:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Bouton copier la requête
              OutlinedButton.icon(
                icon: const Icon(Icons.content_copy, size: 16),
                label: const Text('Copier la requête SQL'),
                onPressed: () => _copyToClipboard(content['sql_data']['query']),
              ),
              const SizedBox(height: 8),
              // Tableau des résultats
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: (content['sql_data']['columns'] as List<String>)
                      .map((col) => DataColumn(label: Text(col)))
                      .toList(),
                  rows: (content['sql_data']['rows'] as List<List<dynamic>>)
                      .take(5)
                      .map((row) => DataRow(
                        cells: row
                            .map((cell) => DataCell(Text(cell.toString())))
                            .toList(),
                      ))
                      .toList(),
                ),
              ),
              if ((content['sql_data']['rows'] as List).length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '... et ${(content['sql_data']['rows'] as List).length - 5} lignes supplémentaires',
                    style: TextStyle(color: theme.secondaryTextColor),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('CTI Assistant'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              reverse: true,
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == 0) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final msgIndex = index - (_isLoading ? 1 : 0);
                final msg = _messages.reversed.toList()[msgIndex];
                final isUser = msg['role'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.85,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? theme.primaryColor : theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isUser ? 'Vous' : 'CTI Assistant',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isUser ? Colors.white : theme.titleColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (isUser)
                          Text(
                            msg['message'],
                            style: TextStyle(color: Colors.white),
                          )
                        else
                          _buildBotMessage(msg['message']),
                      ],
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
                    decoration: InputDecoration(
                      hintText: 'Posez votre question commerciale...',
                      border: InputBorder.none,
                      suffixIcon: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                    ),
                    onSubmitted: _sendMessage,
                    maxLines: null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading
                      ? null
                      : () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}