import 'package:flutter/material.dart'; // Importa il framework Flutter per la gestione della UI.
import 'package:tutormatch/src/core/firebase_util.dart'; // Importa utilità per Firebase.
import 'package:tutormatch/src/models/utente.dart'; // Modello per rappresentare gli utenti.

class HomeStudenteViewModel extends ChangeNotifier {
  // Istanza di FirebaseUtil per interagire con il database Firebase.
  final FirebaseUtil _firebaseUtil = FirebaseUtil();

  // Utente attualmente autenticato.
  Utente? _utente;

  // Stato di caricamento per evitare chiamate simultanee.
  bool _isLoading = false;

  // Getter per l'utente autenticato.
  Utente? get utente => _utente;

  // Getter per lo stato di caricamento.
  bool get isLoading => _isLoading;

  // Mappa per memorizzare i nomi dei tutor associati all'utente.
  Map<String, String> _tutorNomi = {};

  // Getter per accedere ai nomi dei tutor.
  Map<String, String> get tutorNomi => _tutorNomi;

  // Funzione per caricare l'utente e recuperare i nomi dei tutor da valutare.
  Future<void> caricaUtente(String userId) async {
    if (_isLoading) return; // Previene chiamate ripetute.

    _isLoading = true;

    try {
      // Recupera i dati dell'utente dal database.
      var snapshot = await _firebaseUtil.getUserById(userId);
      Map<String, dynamic>? utenteData = snapshot.data() as Map<String, dynamic>?;

      if (utenteData != null) {
        // Crea un oggetto Utente dai dati recuperati.
        _utente = Utente.fromMap(utenteData, userId);

        // Carica i nomi dei tutor da valutare.
        for (String tutorId in _utente!.tutorDaValutare) {
          try {
            // Chiamata a _firebaseUtil per verificare e ottenere i dati del tutor.
            String? nomeCognome = await _firebaseUtil.getNomeDaRef(tutorId);
            if (nomeCognome != null) {
              _tutorNomi[tutorId] = nomeCognome;
            } else {
              // Caso in cui il tutor non esiste.
              print("Utente non trovato per tutorId: $tutorId");
            }
          } catch (e) {
            // Gestione degli errori per un tutor specifico.
            print("Errore durante il caricamento del tutor $tutorId: $e");
          }
        }
      } else {
        // Gestione del caso in cui i dati dell'utente non siano trovati.
        print("Dati dell'utente non trovati per userId: $userId");
      }
    } catch (e) {
      // Gestione degli errori durante il caricamento dell'utente.
      print("Errore durante il caricamento dell'utente: $e");
    } finally {
      // Aggiorna lo stato di caricamento e notifica i listener.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isLoading = false;
        notifyListeners();
      });
    }
  }


  // Funzione per salvare il feedback di un tutor e rimuoverlo dalla lista locale.
  Future<void> salvaFeedback(String tutorId, int feedback) async {
    try {
      // Aggiunge il feedback al profilo del tutor.
      await _firebaseUtil.aggiungiFeedback(tutorId, feedback);

      // Rimuove il tutor dalla lista locale dei tutor da valutare.
      _utente!.tutorDaValutare.remove(tutorId);

      // Aggiorna la lista dei tutor da valutare nel database.
      await _firebaseUtil.aggiornaTutorDaValutare(_utente!.userId, _utente!.tutorDaValutare);

      // Notifica i listener delle modifiche.
      notifyListeners();
    } catch (e) {
      // Gestione degli errori durante il salvataggio del feedback.
      print("Errore durante il salvataggio del feedback: $e");
    }
  }
}
