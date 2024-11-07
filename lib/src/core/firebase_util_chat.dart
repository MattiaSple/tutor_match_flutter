import 'package:firebase_database/firebase_database.dart';

class FirebaseUtileChat {
  final String databaseUrl = "https://tutormatch-a7439-default-rtdb.europe-west1.firebasedatabase.app";
  final DatabaseReference _chatRef = FirebaseDatabase.instance.ref().child('chats');

  Future<DataSnapshot> getAllChats() async {
    try {
      DatabaseEvent event = await _chatRef.once();
      return event.snapshot;
    } catch (e) {
      throw Exception("Errore nel recupero delle chat: $e");
    }
  }

  Stream<DatabaseEvent> getMessagesStream(String chatId) {
    return _chatRef.child(chatId).child('messages').onValue;
  }

  Future<void> sendMessage(String chatId, String senderId, String text) async {
    try {
      DatabaseReference newMessageRef = _chatRef.child(chatId).child('messages').push();
      await newMessageRef.set({
        'senderId': senderId,
        'text': text,
        'timestamp': ServerValue.timestamp, // Usa il timestamp del server qui
      });

      await _chatRef.child(chatId).child('lastMessage').set({
        'senderId': senderId,
        'text': text,
        'timestamp': ServerValue.timestamp, // Anche qui usa il timestamp del server
      });
    } catch (e) {
      throw Exception("Errore nell'invio del messaggio: $e");
    }
  }

  Future<void> createChat(String chatId, Map<String, dynamic> chatData) async {
    try {
      await _chatRef.child(chatId).set(chatData);
      print("Chat creata con successo: $chatId");
    } catch (e) {
      throw Exception("Errore nella creazione della chat: $e");
    }
  }

  Future<bool> checkChatExists(String studenteId, String tutorId, String annuncioId) async {
    try {
      DatabaseEvent event = await _chatRef.orderByChild("participants").once();
      if (event.snapshot.exists) {
        for (var chat in event.snapshot.children) {
          final chatData = chat.value as Map<dynamic, dynamic>;
          final participants = chatData["participants"];
          final subjectId = chatData["subject"];

          if (participants.contains(studenteId) &&
              participants.contains(tutorId) &&
              subjectId == annuncioId) {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      throw Exception("Errore nel controllo dell'esistenza della chat: $e");
    }
  }
  // Ottiene lo stream in tempo reale di tutte le chat
  Stream<DatabaseEvent> getAllChatsStream() {
    return _chatRef.onValue; // Restituisce un flusso degli eventi di cambiamento
  }
  Future<void> deleteChat(String chatId) async {
    try {
      await _chatRef.child(chatId).remove();
      print("Chat eliminata con successo: $chatId");
    } catch (e) {
      throw Exception("Errore durante l'eliminazione della chat: $e");
    }
  }
}
