import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutormatch/src/core/firebase_util.dart';

class ProfiloViewModel extends ChangeNotifier {
  final FirebaseUtil _firebaseUtil = FirebaseUtil();

  // Parametri utente
  String? nome;
  String? cognome;
  bool ruolo = false; // true = tutor, false = studente
  String userId = ''; // Recuperato al login
  List<int> feedback = [];

  // Gestione dello stato di caricamento e degli errori
  bool isLoading = false;
  String? errore;

  // Carica i dati dell'utente
  Future<void> caricaProfilo(String userId) async {
    isLoading = true;
    errore = null;
    notifyListeners();

    try {
      DocumentSnapshot utenteSnapshot = await _firebaseUtil.getUserById(userId);
      nome = utenteSnapshot.get('nome');
      cognome = utenteSnapshot.get('cognome');
      ruolo = utenteSnapshot.get('ruolo');
      feedback = List<int>.from(utenteSnapshot.get('feedback') ?? []);
      this.userId = userId;
    } catch (e) {
      errore = 'Errore durante il caricamento del profilo: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Calcola la media dei feedback
  double get mediaFeedback {
    if (feedback.isEmpty) {
      return 0.0;
    }
    return feedback.reduce((a, b) => a + b) / feedback.length;
  }

  // Aggiorna i dati dell'utente
  Future<void> aggiornaProfilo(String nuovoNome, String nuovoCognome) async {
    isLoading = true;
    errore = null;
    notifyListeners();

    try {
      await _firebaseUtil.aggiornaProfilo(userId, nuovoNome, nuovoCognome);
      nome = nuovoNome;
      cognome = nuovoCognome;
    } catch (e) {
      errore = 'Errore durante l\'aggiornamento del profilo: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
