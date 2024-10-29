import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../core/firebase_util_chat.dart';
import '../models/chat.dart';

class ChatViewModel extends ChangeNotifier {
  final FirebaseUtileChat _firebaseUtileChat = FirebaseUtileChat();
  List<Chat> _chats = [];
  List<Chat> get chats => _chats;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _loggedUserName; // Nome completo dell'utente loggato
  String get loggedUserName => _loggedUserName ?? 'Sconosciuto'; // Getter per il nome

  bool _hasLoadedChats = false; // Aggiunto flag per controllo caricamento
  bool get hasLoadedChats => _hasLoadedChats;

  void setChatsLoaded(bool loaded) {
    _hasLoadedChats = loaded;
    notifyListeners();
  }

  // Recupera tutte le chat per l'utente
  Future<void> loadAllChats(String email, String fullName) async {
    _isLoading = true;
    _loggedUserName = fullName; // Salva il nome completo dell'utente loggato
    notifyListeners();

    try {
      DataSnapshot snapshot = await _firebaseUtileChat.getAllChats();

      if (snapshot.value != null) {
        Map<dynamic, dynamic> chatsData = snapshot.value as Map<dynamic, dynamic>;

        // Filtra solo le chat in cui l'utente è un partecipante
        _chats = chatsData.entries
            .where((entry) {
          List<dynamic> participants = entry.value['participants'];
          return participants.contains(email); // Verifica se l'utente è un partecipante
        })
            .map((entry) => Chat.fromMap(entry.key, entry.value))
            .toList();

        print("ChatViewModel: Chat filtrate - ${_chats.length} chat trovate per $email");
      } else {
        print("ChatViewModel: Nessuna chat trovata");
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("ChatViewModel: Errore nel caricamento delle chat: $e");
    }
  }
}
