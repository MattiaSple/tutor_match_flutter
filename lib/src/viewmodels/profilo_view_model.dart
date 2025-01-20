import 'package:firebase_auth/firebase_auth.dart'; // Per gestire l'autenticazione Firebase.
import 'package:flutter/material.dart'; // Per la gestione della UI con Flutter.
import 'package:cloud_firestore/cloud_firestore.dart'; // Per interagire con il database Firestore.
import 'package:provider/provider.dart'; // Per la gestione dello stato con Provider.
import 'package:tutormatch/src/core/firebase_util.dart'; // Utility per operazioni Firebase.

import 'chat_view_model.dart'; // Importa il ViewModel della chat.

class ProfiloViewModel extends ChangeNotifier {
  // Istanza di FirebaseUtil per operazioni legate al database.
  final FirebaseUtil _firebaseUtil = FirebaseUtil();

  // Parametri utente.
  String? nome; // Nome dell'utente.
  String? cognome; // Cognome dell'utente.
  bool ruolo = false; // Ruolo dell'utente: true = tutor, false = studente.
  String userId = ''; // ID utente recuperato al login.
  List<int> feedback = []; // Lista dei feedback ricevuti.

  // Stato di caricamento e gestione degli errori.
  bool isLoading = false; // Indica se è in corso un'operazione.
  String? errore; // Messaggio d'errore.

  // Carica i dati del profilo utente.
  Future<void> caricaProfilo(String userId) async {
    isLoading = true;
    errore = null;
    notifyListeners(); // Aggiorna la UI.

    try {
      // Recupera i dati dell'utente da Firestore.
      DocumentSnapshot utenteSnapshot = await _firebaseUtil.getUserById(userId);

      // Aggiorna i parametri dell'utente.
      nome = utenteSnapshot.get('nome');
      cognome = utenteSnapshot.get('cognome');
      ruolo = utenteSnapshot.get('ruolo');
      feedback = List<int>.from(utenteSnapshot.get('feedback') ?? []);
      this.userId = userId;
    } catch (e) {
      // Gestione degli errori durante il caricamento.
      errore = 'Errore durante il caricamento del profilo: $e';
    } finally {
      // Termina il caricamento e aggiorna la UI.
      isLoading = false;
      notifyListeners();
    }
  }

  // Calcola la media dei feedback.
  double get mediaFeedback {
    if (feedback.isEmpty) {
      return 0.0; // Restituisce 0 se non ci sono feedback.
    }
    return feedback.reduce((a, b) => a + b) / feedback.length; // Calcola la media.
  }

  // Aggiorna i dati del profilo utente.
  Future<void> aggiornaProfilo(String nuovoNome, String nuovoCognome) async {
    isLoading = true;
    errore = null;
    notifyListeners(); // Aggiorna la UI.

    try {
      // Aggiorna i dati dell'utente in Firestore.
      await _firebaseUtil.aggiornaProfilo(userId, nuovoNome, nuovoCognome);

      // Aggiorna i parametri locali.
      nome = nuovoNome;
      cognome = nuovoCognome;
    } catch (e) {
      // Gestione degli errori durante l'aggiornamento.
      errore = 'Errore durante l\'aggiornamento del profilo: $e';
    } finally {
      // Termina il caricamento e aggiorna la UI.
      isLoading = false;
      notifyListeners();
    }
  }

  // Effettua il logout e reindirizza alla pagina di login.
  Future<void> logoutEReindirizza(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners(); // Aggiorna la UI.

      // Cancella i listener associati ad altri ViewModel.
      Provider.of<ChatViewModel>(context, listen: false).dispose();

      // Effettua il logout da Firebase.
      await FirebaseAuth.instance.signOut();

      // Naviga alla pagina di login e rimuove tutte le pagine precedenti.
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Gestione degli errori durante il logout.
      errore = 'Errore durante il logout: $e';
    } finally {
      // Termina il caricamento e aggiorna la UI.
      isLoading = false;
      notifyListeners();
    }
  }
}
