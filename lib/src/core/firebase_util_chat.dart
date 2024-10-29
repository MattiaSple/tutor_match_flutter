import 'package:firebase_database/firebase_database.dart';

class FirebaseUtileChat {
  final String databaseUrl = "https://tutormatch-a7439-default-rtdb.europe-west1.firebasedatabase.app";
  final DatabaseReference _chatRef = FirebaseDatabase.instance.ref().child('chats'); // Utilizza 'ref' invece di 'reference()'

  // Crea una nuova chat tra due partecipanti e utilizza un ID generato da Firebase
  Future<void> createChat(String subject, List<String> participantsNames) async {
    try {
      // Genera un ID univoco per la chat
      DatabaseReference newChatRef = _chatRef.push();
      String chatId = newChatRef.key!;

      // Salva la chat nel database con il nuovo ID
      await newChatRef.set({
        'id': chatId,
        'subject': subject,
        'lastMessage': {
          'senderId': '',
          'text': '',
          'timestamp': 0,
          'unreadBy': participantsNames,
        },
        'participantsNames': participantsNames,
      });
    } catch (e) {
      throw Exception("Errore nella creazione della chat: $e");
    }
  }
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
  // Stream per ascoltare i messaggi in tempo reale
  Stream<DatabaseEvent> getMessagesStream(String chatId) {
    return FirebaseDatabase.instance.ref('chats/$chatId/messages').onValue;
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
