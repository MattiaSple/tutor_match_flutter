import 'package:flutter/material.dart'; // Importa il framework Flutter per la gestione della UI.
import '../core/firebase_util_chat.dart'; // Utility specifica per gestire le operazioni di chat in Firebase.
import '../core/firebase_util.dart'; // Utility generale per interagire con Firebase.
import '../models/messaggio.dart'; // Modello per rappresentare i messaggi.

class InChatViewModel extends ChangeNotifier {
  // Istanza di FirebaseUtileChat per operazioni specifiche sulle chat.
  final FirebaseUtileChat _firebaseUtileChat = FirebaseUtileChat();

  // Stream per aggiornamenti in tempo reale dei messaggi della chat.
  Stream<List<Messaggio>> getMessagesStream(String chatId) async* {
    // Ottiene lo stream dei messaggi dalla chat specifica.
    final stream = await _firebaseUtileChat.getMessagesStream(chatId);

    // Mappa i dati dello stream in una lista di Messaggio.
    yield* stream.asyncMap((event) {
      if (event.snapshot.value != null) {
        // Converte i dati dello snapshot in una lista di Messaggio.
        final messagesData = event.snapshot.value as Map<dynamic, dynamic>;
        final messages = messagesData.entries
            .map((entry) => Messaggio.fromMap(entry.value))
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp)); // Ordina i messaggi per timestamp.
        return messages;
      }
      return []; // Restituisce una lista vuota se non ci sono messaggi.
    });
  }

  // Invia un messaggio nella chat specificata.
  Future<void> sendMessage(String chatId, String userId, String text) async {
    try {
      // Recupera l'email dell'utente in base all'userId.
      final email = await getEmail(userId);

      // Invia il messaggio tramite Firebase.
      await _firebaseUtileChat.sendMessage(chatId, email, text);

      // Notifica alla UI che c'è stato un cambiamento.
      notifyListeners();
    } catch (e) {
      // Gestisce eventuali errori durante l'invio del messaggio.
      print("Errore durante l'invio del messaggio: $e");
    }
  }

  // Recupera l'email di un utente in base all'userId.
  Future<String> getEmail(String userId) async {
    try {
      return await FirebaseUtil().getEmailByUserId(userId); // Utilizza FirebaseUtil per ottenere l'email.
    } catch (e) {
      // Gestisce eventuali errori durante il recupero dell'email.
      print("Errore durante il recupero dell'email: $e");
      return ''; // Restituisce una stringa vuota in caso di errore.
    }
  }

  // Recupera nome e cognome di un utente in base alla sua email.
  Future<String> getSenderNameByEmail(String email) async {
    try {
      return await FirebaseUtil().getNomeDaEmail(email); // Utilizza FirebaseUtil per ottenere nome e cognome.
    } catch (e) {
      // Gestisce eventuali errori durante il recupero del nome.
      print('Errore nel recupero del nome e cognome da email: $e');
      throw e; // Rilancia l'errore per gestirlo a livello superiore.
    }
  }

  // Imposta il campo "unreadBy" a false per un utente specifico in una chat.
  Future<void> unreadBySetToFalse(String chatId, String userEmail) async {
    _firebaseUtileChat.unreadBySetToFalse(chatId, userEmail); // Aggiorna lo stato dei messaggi non letti.
  }
}
