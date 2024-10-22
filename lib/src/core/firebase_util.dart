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
// Funzione per generare un ID univoco per l'annuncio
  String createAnnuncioId() {
    return _firestore.collection('annunci').doc().id; // Genera un ID univoco
  }

  // Funzione per creare un annuncio con l'ID generato
  Future<void> creaAnnuncio(String userId, String annuncioId, String materia) async {
    try {
      DocumentReference tutorRef = _firestore.collection('utenti').doc(userId); // Salva il DocumentReference

      await _firestore.collection('annunci').doc(annuncioId).set({
        'id': annuncioId,
        'tutor': tutorRef, // Salva direttamente il DocumentReference
        'materia': materia,
      });
    } catch (e) {
      print("Errore durante la creazione dell'annuncio: $e");
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getAnnunciByUserId(String userId) async {
    try {
      DocumentReference tutorRef = _firestore.collection('utenti').doc(userId); // Riferimento all'utente

      QuerySnapshot snapshot = await _firestore
          .collection('annunci')
          .where('tutor', isEqualTo: tutorRef) // Confronto con il DocumentReference
          .get();

      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Errore nel recupero degli annunci: $e');
      throw e;
    }
  }

  // Elimina un annuncio
  Future<void> eliminaAnnuncio(String annuncioId) async {
    try {
      await _firestore.collection('annunci').doc(annuncioId).delete();
    } catch (e) {
      throw Exception('Errore durante l\'eliminazione dell\'annuncio: $e');
    }
  }
// Puoi aggiungere altre funzioni qui per ulteriori interazioni con Firebase
}
