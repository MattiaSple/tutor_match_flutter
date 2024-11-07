import 'dart:async';

import 'package:flutter/material.dart';
import '../core/firebase_util_chat.dart';
import '../core/firebase_util.dart';
import '../models/chat.dart';
import '../models/utente.dart';
import 'dart:math';

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

  StreamSubscription? _chatSubscription;

  void setChatsLoaded(bool loaded) {
    _hasLoadedChats = loaded;
    notifyListeners();
  }
  // Define listenToChats to set up real-time chat loading
  void listenToChats(String userId) {
    _isLoading = true;
    notifyListeners();

    _firebaseUtil.getEmailByUserId(userId).then((email) async {
      if (email != null) {
        String? fullName = await _firebaseUtil.getNomeDaRef(userId);
        if (fullName != null) {
          _loggedUserName = fullName;

          // Set up real-time listener for chats involving the user
          _chatSubscription = _firebaseUtileChat.getAllChatsStream().listen((event) {
            if (event.snapshot.value != null) {
              _chats = event.snapshot.children
                  .where((child) {
                List<dynamic> participants = child.child('participants').value as List<dynamic>;
                return participants.contains(email);
              })
                  .map((child) {
                final chatId = child.key ?? '';
                final chatData = child.value as Map<dynamic, dynamic>;
                return Chat.fromMap(chatId, chatData);
              })
                  .toList();

              print("ChatViewModel: ${_chats.length} chat trovate per $email");
            } else {
              _chats = [];
            }
            _hasLoadedChats = true;
            _isLoading = false;
            notifyListeners();
          }, onError: (error) {
            print("Errore nel caricamento delle chat: $error");
            _isLoading = false;
            notifyListeners();
          });
        } else {
          print("Errore: Nome completo non trovato per l'utente con ID $userId");
        }
      } else {
        print("Errore: Email non trovata per l'utente con ID $userId");
      }
      _isLoading = false;
      notifyListeners();
    }).catchError((e) {
      print("Errore nel caricamento delle informazioni dell'utente: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  // Dispose the subscription to avoid memory leaks
  @override
  void dispose() {
    _chatSubscription?.cancel();
    super.dispose();
  }

  Future<void> creaChat(String studenteId, String tutorId, String annuncioId) async {
    try {
      // Genera un ID univoco combinando il timestamp e un numero casuale
      final random = Random();
      final chatId = 'chat_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(9000) + 1000}';

      // Recupera l'annuncio per ottenere la materia
      final annuncioSnapshot = await _firebaseUtil.getAnnuncioById(annuncioId);
      final Map<String, dynamic> annuncioData = annuncioSnapshot.data() as Map<String, dynamic>;
      final materia = annuncioData['materia'];

      // Recupera i dati dello studente
      final studenteSnapshot = await _firebaseUtil.getUserById(studenteId);
      final Map<String, dynamic> studenteData = studenteSnapshot.data() as Map<String, dynamic>;
      final Utente studente = Utente.fromMap(studenteData, studenteId);

      // Recupera i dati del tutor
      final tutorSnapshot = await _firebaseUtil.getUserById(tutorId);
      final Map<String, dynamic> tutorData = tutorSnapshot.data() as Map<String, dynamic>;
      final Utente tutor = Utente.fromMap(tutorData, tutorId);

      // Controlla se esiste già una chat con questi partecipanti e l'annuncio specificato
      final chatExists = await _firebaseUtileChat.checkChatExists(studente.email, tutor.email, materia);
      if (chatExists) {
        print('La chat esiste già, non è necessario crearne una nuova.');
        return; // Esce dalla funzione se la chat esiste già
      }

      // Struttura della chat da salvare
      final chatData = {
        "id": chatId,
        "lastMessage": {
          "senderId": "", // Campo da aggiornare quando viene inviato un nuovo messaggio
          "text": "",
          "timestamp": DateTime.now().millisecondsSinceEpoch,
          "unreadBy": []
        },
        "messages": {},
        "participants": [
          studente.email,
          tutor.email
        ],
        "participantsNames": [
          "${studente.nome} ${studente.cognome}",
          "${tutor.nome} ${tutor.cognome}"
        ],
        "subject": materia
      };

      // Salva la chat nel database
      await _firebaseUtileChat.createChat(chatId, chatData);
    } catch (e) {
      print('Errore nella creazione della chat: $e');
      throw e;
    }
  }
  Future<void> eliminaChat(String chatId) async {
    try {
      await _firebaseUtileChat.deleteChat(chatId);
      _chats.removeWhere((chat) => chat.id == chatId);
      notifyListeners();
    } catch (e) {
      print("Errore durante l'eliminazione della chat: $e");
    }
  }
}
