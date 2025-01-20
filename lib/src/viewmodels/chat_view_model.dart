import 'dart:async'; // Per gestire Streams e Futures.
import 'dart:math'; // Per generare numeri casuali.
import 'package:flutter/material.dart'; // Framework Flutter per UI.
import '../core/firebase_util_chat.dart'; // Utility specifica per le chat in Firebase.
import '../core/firebase_util.dart'; // Utility generale per Firebase.
import '../models/chat.dart'; // Modello Chat.
import '../models/utente.dart'; // Modello Utente.
import 'package:firebase_database/firebase_database.dart'; // Libreria Firebase per database in tempo reale.

// ViewModel per la gestione delle chat, utilizzato con il pattern MVVM.
class ChatViewModel extends ChangeNotifier {
  // Inizializzazione delle utilità Firebase.
  final FirebaseUtileChat _firebaseUtileChat = FirebaseUtileChat();
  final FirebaseUtil _firebaseUtil = FirebaseUtil();

  // Lista delle chat caricate.
  List<Chat> _chats = [];
  List<Chat> get chats => _chats; // Getter per la lista di chat.

  // Stato di caricamento delle chat.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Informazioni sull'utente autenticato.
  String? _loggedUserName;
  String? _loggedUserEmail;

  // Getter con valore di fallback se le informazioni non sono disponibili.
  String get loggedUserName => _loggedUserName ?? 'Sconosciuto';
  String get loggedUserEmail => _loggedUserEmail ?? 'Email non trovata';

  // Flag per indicare se le chat sono state caricate.
  bool _hasLoadedChats = false;
  bool get hasLoadedChats => _hasLoadedChats;

  // Sottoscrizione a uno stream di chat in Firebase.
  StreamSubscription? _chatSubscription;

  // Imposta il flag per indicare che le chat sono state caricate.
  void setChatsLoaded(bool loaded) {
    _hasLoadedChats = loaded;
    notifyListeners(); // Notifica le modifiche all'interfaccia.
  }

  // Ascolta lo stream delle chat in Firebase per un determinato utente.
  void listenToChats(String userId) {
    if (_chatSubscription != null) {
      print("Listener già attivo, nessuna nuova istanza creata.");
      return; // Evita di creare listener duplicati.
    }

    _isLoading = true;
    notifyListeners();

    // Ottieni l'email dell'utente basandoti sull'ID.
    _firebaseUtil.getEmailByUserId(userId).then((email) async {
      if (email != null) {
        // Recupera altre informazioni dell'utente.
        String? fullName = await _firebaseUtil.getNomeDaRef(userId);
        String? email = await _firebaseUtil.getEmailByUserId(userId);
        if (fullName != null) {
          _loggedUserName = fullName;
          _loggedUserEmail = email;

          // Sottoscrizione allo stream di chat in Firebase.
          _chatSubscription = _firebaseUtileChat.getAllChatsStream().listen((event) {
            if (event.snapshot.value != null) {
              // Filtra le chat in cui l'utente è un partecipante.
              _chats = event.snapshot.children
                  .where((child) {
                List<dynamic> participants = child.child('participants').value as List<dynamic>;
                return participants.contains(email);
              })
                  .map((child) {
                final chatId = child.key ?? '';
                final chatData = child.value as Map<dynamic, dynamic>;
                return Chat.fromMap(chatId, chatData); // Crea un oggetto Chat.
              }).toList();
            } else {
              _chats = []; // Nessuna chat disponibile.
            }
            _hasLoadedChats = true;
            _isLoading = false;
            notifyListeners(); // Aggiorna la UI.
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

  // Cancella lo stream e libera risorse.
  @override
  void dispose() {
    _chatSubscription?.cancel();
    super.dispose();
  }

  // Crea una nuova chat tra studente e tutor.
  Future<void> creaChat(String studenteId, String tutorId, String annuncioId) async {
    try {
      // Genera un ID univoco per la chat.
      final random = Random();
      final chatId = 'chat_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(9000) + 1000}';

      // Recupera dati dell'annuncio.
      final annuncioSnapshot = await _firebaseUtil.getAnnuncioById(annuncioId);
      final Map<String, dynamic> annuncioData = annuncioSnapshot.data() as Map<String, dynamic>;
      final materia = annuncioData['materia'];

      // Recupera dati dello studente.
      final studenteSnapshot = await _firebaseUtil.getUserById(studenteId);
      final Map<String, dynamic> studenteData = studenteSnapshot.data() as Map<String, dynamic>;
      final Utente studente = Utente.fromMap(studenteData, studenteId);

      // Recupera dati del tutor.
      final tutorSnapshot = await _firebaseUtil.getUserById(tutorId);
      final Map<String, dynamic> tutorData = tutorSnapshot.data() as Map<String, dynamic>;
      final Utente tutor = Utente.fromMap(tutorData, tutorId);

      // Controlla se la chat esiste già.
      final chatExists = await _firebaseUtileChat.checkChatExists(studente.email, tutor.email, materia);
      if (chatExists) {
        return; // Esce se la chat esiste già.
      }

      // Dati per creare una nuova chat.
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

      // Crea la nuova chat in Firebase.
      await _firebaseUtileChat.createChat(chatId, chatData);
    } catch (e) {
      print('Errore nella creazione della chat: $e');
      throw e; // Rilancia l'errore per ulteriori gestioni.
    }
  }

  // Elimina una chat specifica.
  Future<void> eliminaChat(String chatId) async {
    try {
      // Elimina la chat in Firebase.
      await _firebaseUtileChat.deleteChat(chatId);
      _chats.removeWhere((chat) => chat.id == chatId); // Rimuove la chat dalla lista locale.
      notifyListeners(); // Aggiorna la UI.
    } catch (e) {
      print("Errore durante l'eliminazione della chat: $e");
    }
  }
}
