import 'package:firebase_database/firebase_database.dart'; // Importa il database Firebase Realtime Database.

class FirebaseUtileChat {
  // URL del database Firebase.
  final String databaseUrl = "https://tutormatch-a7439-default-rtdb.europe-west1.firebasedatabase.app";

  // Riferimento alla collezione 'chats' nel database.
  final DatabaseReference _chatRef = FirebaseDatabase.instance.ref().child('chats');

  // Recupera tutte le chat una sola volta.
  Future<DataSnapshot> getAllChats() async {
    try {
      // Ottiene i dati delle chat tramite una singola richiesta.
      DatabaseEvent event = await _chatRef.once();
      return event.snapshot;
    } catch (e) {
      // Lancia un'eccezione in caso di errore.
      throw Exception("Errore nel recupero delle chat: $e");
    }
  }

  // Restituisce lo stream dei messaggi di una chat specifica.
  Future<Stream<DatabaseEvent>> getMessagesStream(String chatId) async {
    return _chatRef.child(chatId).child('messages').onValue; // Stream dei messaggi.
  }

  // Invia un messaggio in una chat specifica.
  Future<void> sendMessage(String chatId, String senderId, String text) async {
    try {
      // Recupera i dati della chat specifica.
      DataSnapshot chatSnapshot = await _chatRef.child(chatId).get();

      if (!chatSnapshot.exists) {
        // Lancia un'eccezione se la chat non esiste.
        throw Exception("Chat non trovata: $chatId");
      }

      // Ottiene i partecipanti alla chat.
      Map<dynamic, dynamic> chatData = chatSnapshot.value as Map<dynamic, dynamic>;
      List<dynamic> participants = chatData['participants'] ?? [];

      // Determina chi non ha ancora letto il messaggio.
      String unreadBy = participants.firstWhere((participant) => participant != senderId, orElse: () => "");

      // Riferimento al nuovo messaggio.
      DatabaseReference newMessageRef = _chatRef.child(chatId).child('messages').push();

      // Aggiorna il campo lastMessage e aggiunge il nuovo messaggio.
      await _chatRef.child(chatId).child('lastMessage').set({
        'senderId': senderId,
        'text': text,
        'timestamp': ServerValue.timestamp,
        'unreadBy': unreadBy.isNotEmpty ? [unreadBy] : [],
      });
      await newMessageRef.set({
        'senderId': senderId,
        'text': text,
        'timestamp': ServerValue.timestamp,
        'unreadBy': unreadBy.isNotEmpty ? [unreadBy] : [],
      });
    } catch (e) {
      // Lancia un'eccezione in caso di errore.
      throw Exception("Errore nell'invio del messaggio: $e");
    }
  }

  // Crea una nuova chat con i dati forniti.
  Future<void> createChat(String chatId, Map<String, dynamic> chatData) async {
    try {
      await _chatRef.child(chatId).set(chatData); // Salva i dati della chat.
      print("Chat creata con successo: $chatId");
    } catch (e) {
      // Lancia un'eccezione in caso di errore.
      throw Exception("Errore nella creazione della chat: $e");
    }
  }

  // Controlla se una chat esiste già con determinati parametri.
  Future<bool> checkChatExists(String studenteId, String tutorId, String annuncioId) async {
    try {
      // Recupera tutte le chat e verifica le condizioni.
      DatabaseEvent event = await _chatRef.orderByChild("participants").once();
      if (event.snapshot.exists) {
        for (var chat in event.snapshot.children) {
          final chatData = chat.value as Map<dynamic, dynamic>;
          final participants = chatData["participants"];
          final subjectId = chatData["subject"];

          if (participants.contains(studenteId) &&
              participants.contains(tutorId) &&
              subjectId == annuncioId) {
            return true; // La chat esiste.
          }
        }
      }
      return false; // La chat non esiste.
    } catch (e) {
      // Lancia un'eccezione in caso di errore.
      throw Exception("Errore nel controllo dell'esistenza della chat: $e");
    }
  }

  // Restituisce uno stream in tempo reale di tutte le chat.
  Stream<DatabaseEvent> getAllChatsStream() {
    return _chatRef.onValue; // Stream di tutte le chat.
  }

  // Elimina una chat specifica tramite il suo ID.
  Future<void> deleteChat(String chatId) async {
    try {
      // Rimuove la chat dal database.
      await _chatRef.child(chatId).remove();
      print("Chat eliminata con successo: $chatId");
    } catch (e) {
      // Lancia un'eccezione in caso di errore.
      throw Exception("Errore durante l'eliminazione della chat: $e");
    }
  }

  // Imposta il campo `unreadBy` a una lista vuota per un utente specifico.
  Future<void> unreadBySetToFalse(String chatId, String userEmail) async {
    try {
      // Recupera i dati della chat specifica.
      DataSnapshot chatSnapshot = await _chatRef.child(chatId).get();

      if (!chatSnapshot.exists) {
        throw Exception("Chat non trovata: $chatId"); // Lancia un'eccezione se la chat non esiste.
      }

      // Verifica se l'email è presente in `unreadBy`.
      Map<dynamic, dynamic>? lastMessage = chatSnapshot.child('lastMessage').value as Map<dynamic, dynamic>?;
      List<dynamic>? unreadBy = lastMessage?['unreadBy'] as List<dynamic>?;

      if (unreadBy != null && unreadBy.contains(userEmail)) {
        // Aggiorna il campo `unreadBy` con una lista vuota.
        await _chatRef.child(chatId).child('lastMessage').update({
          'unreadBy': [],
        });
        print("UnreadBy impostato a lista vuota per la chat: $chatId");
      } else {
        print("L'email non è presente nel campo unreadBy, nessun aggiornamento effettuato.");
      }
    } catch (e) {
      // Lancia un'eccezione in caso di errore.
      throw Exception("Errore durante l'aggiornamento di unreadBy: $e");
    }
  }
}
