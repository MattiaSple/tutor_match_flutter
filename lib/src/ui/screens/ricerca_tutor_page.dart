import 'package:flutter/material.dart';

class RicercaTutorPage extends StatelessWidget {
  final String userId;
  final bool ruolo;

  const RicercaTutorPage({required this.userId, required this.ruolo, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ricerca Tutor'),
      ),
      body: Center(
        child: Text(
          'Ricerca Tutor per UserID: $userId\nRuolo: ${ruolo ? "Tutor" : "Studente"}',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
