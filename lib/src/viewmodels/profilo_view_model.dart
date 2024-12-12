import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/core/firebase_util.dart';

import 'chat_view_model.dart';

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

  // Funzione di logout e reindirizzamento
  Future<void> logoutEReindirizza(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      // Cancella listener di chat e altri ViewModel
      Provider.of<ChatViewModel>(context, listen: false).dispose();

      // Effettua il logout da Firebase
      await FirebaseAuth.instance.signOut();

      // Naviga alla pagina di login e rimuove tutte le pagine precedenti
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      errore = 'Errore durante il logout: $e';
    } finally {
      isLoading = false;
      notifyListeners(); // Aggiorna la UI
    }
  }

}
