import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tutormatch/src/core/firebase_util.dart'; // Importa FirebaseUtil

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseUtil _firebaseUtil = FirebaseUtil(); // Istanzia FirebaseUtil

  User? get currentUser => _auth.currentUser;

  // Stream che restituisce i cambiamenti dello stato di autenticazione
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login con email e password
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      //await _firebaseUtil.verificaFirebaseInizializzato();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
    } catch (e) {
      print("Errore nel login: $e");
      throw e;  // Rilancia l'errore per gestirlo nella UI
    }
  }

  // Recupera il ruolo dell'utente dal database tramite FirebaseUtil
  Future<bool> getUserRole(String userId) async {
    try {
      return await _firebaseUtil.getUserRole(userId);
    } catch (e) {
      throw e;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}
