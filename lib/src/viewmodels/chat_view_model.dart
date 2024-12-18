import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/firebase_util_chat.dart';
import '../core/firebase_util.dart';
import '../models/chat.dart';
import '../models/utente.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatViewModel extends ChangeNotifier {
  final FirebaseUtileChat _firebaseUtileChat = FirebaseUtileChat();
  final FirebaseUtil _firebaseUtil = FirebaseUtil();
  List<Chat> _chats = [];
  List<Chat> get chats => _chats;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _loggedUserName;
  String? _loggedUserEmail;

  String get loggedUserName => _loggedUserName ?? 'Sconosciuto';
  String get loggedUserEmail => _loggedUserEmail ?? 'Email non trovata';

  bool _hasLoadedChats = false;
  bool get hasLoadedChats => _hasLoadedChats;

  StreamSubscription? _chatSubscription;

  void setChatsLoaded(bool loaded) {
    _hasLoadedChats = loaded;
    notifyListeners();
  }

  void listenToChats(String userId) {
    if (_chatSubscription != null) {
      print("Listener già attivo, nessuna nuova istanza creata.");
      return;
    }

    _isLoading = true;
    notifyListeners();

    _firebaseUtil.getEmailByUserId(userId).then((email) async {
      if (email != null) {
        String? fullName = await _firebaseUtil.getNomeDaRef(userId);
        String? email = await _firebaseUtil.getEmailByUserId(userId);
        if (fullName != null) {
          _loggedUserName = fullName;
          _loggedUserEmail = email;

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
              }).toList();

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

  @override
  void dispose() {
    _chatSubscription?.cancel();
    super.dispose();
  }

  Future<void> creaChat(String studenteId, String tutorId, String annuncioId) async {
    try {
      final random = Random();
      final chatId = 'chat_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(9000) + 1000}';

      final annuncioSnapshot = await _firebaseUtil.getAnnuncioById(annuncioId);
      final Map<String, dynamic> annuncioData = annuncioSnapshot.data() as Map<String, dynamic>;
      final materia = annuncioData['materia'];

      final studenteSnapshot = await _firebaseUtil.getUserById(studenteId);
      final Map<String, dynamic> studenteData = studenteSnapshot.data() as Map<String, dynamic>;
      final Utente studente = Utente.fromMap(studenteData, studenteId);

      final tutorSnapshot = await _firebaseUtil.getUserById(tutorId);
      final Map<String, dynamic> tutorData = tutorSnapshot.data() as Map<String, dynamic>;
      final Utente tutor = Utente.fromMap(tutorData, tutorId);

      final chatExists = await _firebaseUtileChat.checkChatExists(studente.email, tutor.email, materia);
      if (chatExists) {
        print('La chat esiste già.');
        return;
      }

      final chatData = {
        "id": chatId,
        "lastMessage": {
          "senderId": "",
          "text": "",
          "timestamp": ServerValue.timestamp,
          "unreadBy": []
        },
        "messages": {},
        "participants": [studente.email, tutor.email],
        "participantsNames": ["${studente.nome} ${studente.cognome}", "${tutor.nome} ${tutor.cognome}"],
        "subject": materia
      };

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
