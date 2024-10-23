import 'package:flutter/material.dart';
import 'package:tutormatch/src/core/firebase_util.dart';
import 'package:tutormatch/src/models/utente.dart';

class HomeStudenteViewModel extends ChangeNotifier {
  final FirebaseUtil _firebaseUtil = FirebaseUtil();
  Utente? _utente;
  bool _isLoading = false;

  Utente? get utente => _utente;
  bool get isLoading => _isLoading;

  // Funzione per caricare l'utente
  Future<void> caricaUtente(String userId) async {
    if (_isLoading) return; // Evita chiamate ripetute

    _isLoading = true;

    try {
      print("Inizio caricamento utente...");
      // Modifica qui: otteniamo il documento e chiamiamo il metodo data() per ottenere la mappa
      var snapshot = await _firebaseUtil.getUserById(userId);
      Map<String, dynamic>? utenteData = snapshot.data() as Map<String, dynamic>?; // Usa .data() per accedere ai dati

      if (utenteData != null) {
        _utente = Utente.fromMap(utenteData, userId);
        print("Utente caricato: ${_utente!.nome} ${_utente!.cognome}");
      } else {
        print("Dati dell'utente non trovati.");
      }

      // Utilizza addPostFrameCallback per notificare i listener dopo il rendering
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      print("Errore durante il caricamento dell'utente: $e");
      // Anche in caso di errore, aggiungi il post frame callback per aggiornare lo stato
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  List<String> get tutorDaValutare {
    return _utente?.tutorDaValutare ?? [];
  }
}
