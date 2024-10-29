import 'package:flutter/material.dart';
import 'package:tutormatch/src/core/firebase_util.dart';
import 'package:tutormatch/src/models/utente.dart';

class HomeStudenteViewModel extends ChangeNotifier {
  final FirebaseUtil _firebaseUtil = FirebaseUtil();
  Utente? _utente;
  bool _isLoading = false;

  Utente? get utente => _utente;
  bool get isLoading => _isLoading;

  Map<String, String> _tutorNomi = {}; // Map per memorizzare i nomi dei tutor

  Map<String, String> get tutorNomi => _tutorNomi;

  // Funzione per caricare l'utente e recuperare i nomi dei tutor da valutare
  Future<void> caricaUtente(String userId) async {
    if (_isLoading) return; // Evita chiamate ripetute

    _isLoading = true;

    try {
      var snapshot = await _firebaseUtil.getUserById(userId);
      Map<String, dynamic>? utenteData = snapshot.data() as Map<String, dynamic>?;

      if (utenteData != null) {
        _utente = Utente.fromMap(utenteData, userId);

        // Carica i nomi dei tutor da valutare
        for (String tutorId in _utente!.tutorDaValutare) {
          String nomeCognome = await _firebaseUtil.getNomeDaRef(tutorId);
          _tutorNomi[tutorId] = nomeCognome;
        }
      } else {
        print("Dati dell'utente non trovati.");
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      print("Errore durante il caricamento dell'utente: $e");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  // Funzione per salvare il feedback al tutor e rimuoverlo dalla lista tutorDaValutare
  Future<void> salvaFeedback(String tutorId, int feedback) async {
    try {
      // Aggiungi il feedback al profilo del tutor
      await _firebaseUtil.aggiungiFeedback(tutorId, feedback);

      // Rimuovi il tutor dalla lista locale
      _utente!.tutorDaValutare.remove(tutorId);

      // Aggiorna il campo tutorDaValutare nel profilo dell'utente nel database
      await _firebaseUtil.aggiornaTutorDaValutare(_utente!.userId, _utente!.tutorDaValutare);

      notifyListeners();
    } catch (e) {
      print("Errore durante il salvataggio del feedback: $e");
    }
  }
}


