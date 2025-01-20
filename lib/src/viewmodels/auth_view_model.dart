import 'package:firebase_auth/firebase_auth.dart'; // Importa FirebaseAuth per gestire l'autenticazione.
import 'package:flutter/material.dart'; // Importa Flutter per la gestione della UI.
import 'package:tutormatch/src/core/firebase_util.dart'; // Importa FirebaseUtil per operazioni su Firebase.

class AuthViewModel extends ChangeNotifier {
  // Istanza di FirebaseAuth per gestire le operazioni di autenticazione.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Istanza di FirebaseUtil per interagire con il database.
  final FirebaseUtil _firebaseUtil = FirebaseUtil();

  // Restituisce l'utente attualmente autenticato, se esiste.
  User? get currentUser => _auth.currentUser;

  // Stream che notifica i cambiamenti dello stato di autenticazione.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Metodo per effettuare il login con email e password.
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Effettua il login utilizzando le credenziali fornite.
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Notifica alla UI che lo stato è cambiato.
      notifyListeners();
    } catch (e) {
      // Stampa l'errore e lo rilancia per gestirlo nella UI.
      print("Errore nel login: $e");
      throw e;
    }
  }

  // Metodo per recuperare il ruolo dell'utente dal database.
  Future<bool> getUserRole(String userId) async {
    try {
      // Restituisce il ruolo dell'utente corrispondente all'ID fornito.
      return await _firebaseUtil.getUserRole(userId);
    } catch (e) {
      // Rilancia l'errore per gestirlo a livello superiore.
      throw e;
    }
  }

  // Metodo per effettuare il logout.
  Future<void> signOut() async {
    // Effettua il logout dall'account corrente.
    await _auth.signOut();

    // Notifica alla UI che lo stato è cambiato.
    notifyListeners();
  }
}

