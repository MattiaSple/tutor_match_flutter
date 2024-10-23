import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String userId;
  final bool ruolo;

  const ChatPage({required this.userId, required this.ruolo, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Center(
        child: Text(
          'Chat per UserID: $userId\nRuolo: ${ruolo ? "Tutor" : "Studente"}',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
