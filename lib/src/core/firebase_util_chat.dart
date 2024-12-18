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

  Future<Stream<DatabaseEvent>> getMessagesStream(String chatId, String email) async {
    final snapshot = await _chatRef.child(chatId).child('lastMessage').once();
    if (snapshot.snapshot.exists) {
      final lastMessage = snapshot.snapshot.value as Map?;
      if (lastMessage != null && lastMessage['unreadBy'] != null) {
        if (lastMessage['unreadBy'].contains(email)) {
          await _chatRef.child(chatId).child('lastMessage').update({
            'unreadBy': "", // Aggiorna il campo a stringa vuota
          });
        }
      }
    }
    // Ritorna lo stream dei messaggi
    return _chatRef.child(chatId).child('messages').onValue;
  }

  Future<void> sendMessage(String chatId, String senderId, String text) async {
    try {
      DataSnapshot chatSnapshot = await _chatRef.child(chatId).get();
      if (!chatSnapshot.exists) {
        throw Exception("Chat non trovata: $chatId");
      }

      Map<dynamic, dynamic> chatData = chatSnapshot.value as Map<dynamic, dynamic>;
      List<dynamic> participants = chatData['participants'] ?? [];

      String unreadBy = participants.firstWhere((participant) => participant != senderId, orElse: () => "");

      DatabaseReference newMessageRef = _chatRef.child(chatId).child('messages').push();
      await newMessageRef.set({
        'senderId': senderId,
        'text': text,
        'timestamp': ServerValue.timestamp,
        'unreadBy': unreadBy.isNotEmpty ? [unreadBy] : [],
      });

      await _chatRef.child(chatId).child('lastMessage').set({
        'senderId': senderId,
        'text': text,
        'timestamp': ServerValue.timestamp,
        'unreadBy': unreadBy.isNotEmpty ? [unreadBy] : [],
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

  Stream<DatabaseEvent> getAllChatsStream() {
    return _chatRef.onValue;
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await _chatRef.child(chatId).remove();
      print("Chat eliminata con successo: $chatId");
    } catch (e) {
      throw Exception("Errore durante l'eliminazione della chat: $e");
    }
  }
  Future<void> unreadBySetToFalse(String chatId) async {
    try {
      // Recupera i dati della chat specifica
      DataSnapshot chatSnapshot = await _chatRef.child(chatId).get();

      if (!chatSnapshot.exists) {
        throw Exception("Chat non trovata: $chatId");
      }

      // Aggiorna il lastMessage impostando unreadBy come lista vuota
      await _chatRef.child(chatId).child('lastMessage').update({
        'unreadBy': [],
      });

      print("UnreadBy impostato a lista vuota per la chat: $chatId");
    } catch (e) {
      throw Exception("Errore durante l'aggiornamento di unreadBy: $e");
    }
  }
}
