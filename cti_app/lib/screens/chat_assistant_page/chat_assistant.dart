// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:cti_app/constants/app_constant.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:cti_app/widgets/typing_indicator.dart';
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
            // Bouton copier la requête
            OutlinedButton.icon(
              icon: const Icon(Icons.content_copy, size: 16),
              label: const Text('Copier les résultats'),
              onPressed: () => _copyQueryResults(content['sql_data']),
            ),
            const SizedBox(height: 8),
            // Affichage des résultats sous forme de liste
            ..._buildDataDisplay(content['sql_data'], theme),
          ],
        ),
    ],
  );
}

List<Widget> _buildDataDisplay(Map<String, dynamic> sqlData, ThemeProvider theme) {
  final columns = sqlData['columns'] as List<String>;
  final rows = sqlData['rows'] as List<List<dynamic>>;
  
  // Pour les requêtes simples (1 colonne)
  if (columns.length == 1) {
    return [
      ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 200),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: rows.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                rows[index][0].toString(),
                style: TextStyle(color: theme.textColor),
              ),
            );
          },
        ),
      ),
      Text(
        '${rows.length} résultats',
        style: TextStyle(color: theme.secondaryTextColor, fontSize: 12),
      ),
    ];
  }
  
  // Pour les requêtes multi-colonnes
  return [
    SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns.map((col) => DataColumn(label: Text(col))).toList(),
        rows: rows.take(10).map((row) => DataRow(
          cells: row.map((cell) => DataCell(Text(cell.toString()))).toList(),
        )).toList(),
      ),
    ),
    if (rows.length > 10)
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          '... et ${rows.length - 10} lignes supplémentaires',
          style: TextStyle(color: theme.secondaryTextColor),
        ),
      ),
  ];
}

Future<void> _copyQueryResults(Map<String, dynamic> sqlData) async {
  final columns = sqlData['columns'] as List<String>;
  final rows = sqlData['rows'] as List<List<dynamic>>;
  
  String result = '${columns.join('\t')}\n';
  for (var row in rows) {
    result += '${row.map((cell) => cell.toString()).join('\t')}\n';
  }
  
  await Clipboard.setData(ClipboardData(text: result));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('${rows.length} résultats copiés')),
  );
}

Future<void> _copyMessageText(dynamic message) async {
  String textToCopy;
  
  if (message is String) {
    // Message utilisateur simple
    textToCopy = message;
  } else if (message is Map<String, dynamic>) {
    // Message du bot
    if (message.containsKey('error')) {
      textToCopy = message['error'];
    } else {
      textToCopy = message['human_response'] ?? '';
      if (message['has_sql'] == true && message['sql_data'] != null) {
        textToCopy += '\n\nRequête SQL:\n${message['sql_data']['query']}';
      }
    }
  } else {
    textToCopy = 'Impossible de copier ce message';
  }

  await _copyToClipboard(textToCopy);
}

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('CTI Assistant'),
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
                      child:  TypingIndicator(),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isUser ? 'Vous' : 'CTI Assistant',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isUser ? Colors.white : theme.titleColor,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.content_copy,
                                size: 16,
                                color: isUser ? Colors.white70 : theme.secondaryTextColor,
                              ),
                              onPressed: () => _copyMessageText(msg['message']),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
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
                      hintText: 'Envoyez ta demande...',
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