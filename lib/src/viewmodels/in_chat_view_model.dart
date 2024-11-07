import 'package:flutter/material.dart';
import '../core/firebase_util_chat.dart';
import '../core/firebase_util.dart';
import '../models/messaggio.dart';

class InChatViewModel extends ChangeNotifier {
  final FirebaseUtileChat _firebaseUtileChat = FirebaseUtileChat();

  // Stream per aggiornamenti in tempo reale della chat
  Stream<List<Messaggio>> getMessagesStream(String chatId) {
    return _firebaseUtileChat.getMessagesStream(chatId).map((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> messagesData = event.snapshot.value as Map<dynamic, dynamic>;
        return messagesData.entries
            .map((entry) => Messaggio.fromMap(entry.value))
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp)); // Ordina per data
      }
      return [];
    });
  }

  // Invia un messaggio nella chat
  Future<void> sendMessage(String chatId, String userId, String text) async {
    try {
      final email = await getEmail(userId);

      await _firebaseUtileChat.sendMessage(chatId, email, text);
      notifyListeners();
    } catch (e) {
      print("Errore durante l'invio del messaggio: $e");
    }
  }

  // Recupera l'email di un utente in base all'userId
  Future<String> getEmail(String userId) async {
    try {
      return await FirebaseUtil().getEmailByUserId(userId);
    } catch (e) {
      print("Errore durante il recupero dell'email: $e");
      return '';
    }
  }
  // Funzione per ottenere nome e cognome in base all'email dell'utente
  Future<String> getSenderNameByEmail(String email) async {
    try {
      return await FirebaseUtil().getNomeDaEmail(email);
    } catch (e) {
      print('Errore nel recupero del nome e cognome da email: $e');
      throw e;
    }
  }
}
