import 'package:flutter/material.dart';
import '../core/firebase_util_chat.dart';
import '../core/firebase_util.dart';
import '../models/messaggio.dart';

class InChatViewModel extends ChangeNotifier {
  final FirebaseUtileChat _firebaseUtileChat = FirebaseUtileChat();
  List<Messaggio> _messages = [];
  List<Messaggio> get messages => _messages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _messagesLoaded = false; // Traccia se i messaggi sono caricati
  bool get messagesLoaded => _messagesLoaded;

  // Carica i messaggi per una chat specifica
  Future<void> loadMessages(String chatId) async {
    _isLoading = true;
    _messagesLoaded = false; // Resetta lo stato dei messaggi caricati
    notifyListeners();

    try {
      final snapshot = await _firebaseUtileChat.getMessages(chatId);
      if (snapshot.value != null) {
        Map<dynamic, dynamic> messagesData = snapshot.value as Map<dynamic, dynamic>;
        _messages = messagesData.entries
            .map((entry) => Messaggio.fromMap(entry.value))
            .toList();
        _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp)); // Ordina per data
      }
    } catch (e) {
      print("Errore nel caricamento dei messaggi: $e");
    } finally {
      _isLoading = false;
      _messagesLoaded = true; // Imposta i messaggi come caricati
      notifyListeners();
    }
  }

  // Invia un messaggio nella chat
  Future<void> sendMessage(String chatId, String userId, String text) async {
    try {
      final email = await getEmail(userId);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final message = Messaggio(senderId: email, text: text, timestamp: timestamp);

      await _firebaseUtileChat.sendMessage(chatId, email, text, timestamp);
      _messages.add(message);
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
}
