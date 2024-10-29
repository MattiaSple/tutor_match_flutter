import 'package:firebase_database/firebase_database.dart';

class FirebaseUtileChat {
  final String databaseUrl = "https://tutormatch-a7439-default-rtdb.europe-west1.firebasedatabase.app";
  final DatabaseReference _chatRef = FirebaseDatabase.instance.ref().child('chats'); // Utilizza 'ref' invece di 'reference()'

  // Recupera tutte le chat
  Future<DataSnapshot> getAllChats() async {
    try {
      DatabaseEvent event = await _chatRef.once();
      return event.snapshot;
    } catch (e) {
      throw Exception("Errore nel recupero delle chat: $e");
    }
  }
  // Recupera i messaggi di una chat specifica
  Future<DataSnapshot> getMessages(String chatId) async {
    try {
      DatabaseEvent event = await _chatRef.child(chatId).child('messages').once();
      return event.snapshot;
    } catch (e) {
      throw Exception("Errore nel recupero dei messaggi: $e");
    }
  }

  // Invia un messaggio in una chat
  Future<void> sendMessage(String chatId, String senderId, String text, int timestamp) async {
    try {
      DatabaseReference newMessageRef = _chatRef.child(chatId).child('messages').push();
      await newMessageRef.set({
        'senderId': senderId,
        'text': text,
        'timestamp': timestamp,
      });

      // Aggiorna il lastMessage
      await _chatRef.child(chatId).child('lastMessage').set({
        'senderId': senderId,
        'text': text,
        'timestamp': timestamp,
      });
    } catch (e) {
      throw Exception("Errore nell'invio del messaggio: $e");
    }
  }
}
