import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../core/firebase_util_chat.dart';
import '../core/firebase_util.dart';
import '../models/chat.dart';
import '../models/utente.dart';

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

  Future<void> creaChat(String studenteId, String tutorId, String annuncioId) async {
    try {
      // Genera un ID univoco per la chat in base agli ID degli utenti
      final chatId = createChatId(studenteId, tutorId);

      // Recupera l'annuncio per ottenere la materia
      final annuncioSnapshot = await _firebaseUtil.getAnnuncioById(annuncioId);
      final Map<String, dynamic> annuncioData = annuncioSnapshot.data() as Map<String, dynamic>;
      final materia = annuncioData['materia'] ?? 'Materia non specificata';

      // Recupera i dati dello studente
      final studenteSnapshot = await _firebaseUtil.getUserById(studenteId);
      final Map<String, dynamic> studenteData = studenteSnapshot.data() as Map<String, dynamic>;
      final Utente studente = Utente.fromMap(studenteData, studenteId);

      // Recupera i dati del tutor
      final tutorSnapshot = await _firebaseUtil.getUserById(tutorId);
      final Map<String, dynamic> tutorData = tutorSnapshot.data() as Map<String, dynamic>;
      final Utente tutor = Utente.fromMap(tutorData, tutorId);

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
// Funzione per generare un ID univoco per la chat, combinando gli ID dei due utenti
  String createChatId(String studenteId, String tutorId) {
    return studenteId.compareTo(tutorId) < 0 ? "$studenteId-$tutorId" : "$tutorId-$studenteId";
  }
}
