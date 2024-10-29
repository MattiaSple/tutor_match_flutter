import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Restituisce l'utente attualmente loggato
  User? get currentUser => _firebaseAuth.currentUser;

  // Restituisce un flusso che emette lo stato di autenticazione
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Esegue il login con email e password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }


  // Effettua il logout
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
