import 'package:flutter/material.dart'; // Importa il framework Flutter per la gestione della UI.
import 'package:tutormatch/src/core/firebase_util.dart'; // Importa utilità per interagire con Firebase.

class AnnuncioViewModel extends ChangeNotifier {
  // Istanza di FirebaseUtil per operazioni su Firebase.
  final FirebaseUtil _firebaseUtil = FirebaseUtil();

  // Lista locale degli annunci.
  List<Map<String, dynamic>> _annunci = [];

  // Getter per accedere agli annunci.
  List<Map<String, dynamic>> get annunci => _annunci;

  // Metodo per creare un nuovo annuncio.
  Future<void> creaAnnuncio(String userId, String materia) async {
    try {
      // Genera un ID univoco per l'annuncio.
      String annuncioId = _firebaseUtil.createAnnuncioId();

      // Crea un nuovo annuncio in Firebase con l'ID generato.
      await _firebaseUtil.creaAnnuncio(userId, annuncioId, materia);

      // Notifica alla UI che è stato creato un nuovo annuncio.
      notifyListeners();
    } catch (e) {
      // Gestisce eventuali errori durante la creazione dell'annuncio.
      print("Errore durante la creazione dell'annuncio: $e");
    }
  }

  // Metodo per ottenere tutti gli annunci associati a un utente.
  Future<void> getAnnunciByUserId(String userId) async {
    try {
      // Recupera gli annunci dall'utente specificato.
      _annunci = await _firebaseUtil.getAnnunciByUserId(userId);

      // Notifica alla UI che la lista degli annunci è stata aggiornata.
      notifyListeners();
    } catch (e) {
      // Gestisce eventuali errori durante il recupero degli annunci.
      print('Errore nel recupero degli annunci: $e');
    }
  }

  // Metodo per eliminare un annuncio specifico.
  Future<void> eliminaAnnuncio(String annuncioId) async {
    // Elimina l'annuncio da Firebase.
    await _firebaseUtil.eliminaAnnuncio(annuncioId);

    // Rimuove l'annuncio dalla lista locale.
    _annunci.removeWhere((annuncio) => annuncio['id'] == annuncioId);

    // Notifica alla UI che l'annuncio è stato eliminato.
    notifyListeners();
  }
}
