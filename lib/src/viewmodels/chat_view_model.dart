import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../core/firebase_util_chat.dart';
import '../core/firebase_util.dart';
import '../models/chat.dart';

class ChatViewModel extends ChangeNotifier {
  final FirebaseUtileChat _firebaseUtileChat = FirebaseUtileChat();
  final FirebaseUtil _firebaseUtil = FirebaseUtil(); // Istanza per FirebaseUtil
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

  // Funzione per caricare tutte le chat con le informazioni dell'utente
  Future<void> loadChatsWithUserInfo(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Recupera l'email e il nome completo dell'utente
      String email = await _firebaseUtil.getEmailByUserId(userId);
      String fullName = await _firebaseUtil.getNomeDaRef(userId);
      _loggedUserName = fullName;

      // Carica le chat usando l'email
      await _loadAllChats(email);
      _hasLoadedChats = true; // Imposta il flag dopo il caricamento iniziale
    } catch (e) {
      print("Errore nel caricamento delle informazioni dell'utente: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Recupera tutte le chat per l'utente
  Future<void> _loadAllChats(String email) async {
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
    } catch (e) {
      print("ChatViewModel: Errore nel caricamento delle chat: $e");
    }
  }
}
