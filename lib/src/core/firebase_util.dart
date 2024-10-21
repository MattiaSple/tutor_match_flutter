import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUtil {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Recupera il ruolo dell'utente dal database
  Future<bool> getUserRole(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('utenti').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.get('ruolo'); // true = tutor, false = studente
      } else {
        throw Exception('Utente non trovato');
      }
    } catch (e) {
      print("Errore nel recupero del ruolo: $e");
      throw e;
    }
  }

// Puoi aggiungere altre funzioni qui per ulteriori interazioni con Firebase
}
