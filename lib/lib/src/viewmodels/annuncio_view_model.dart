import 'package:flutter/material.dart';
import 'package:tutormatch/src/core/firebase_util.dart';

class AnnuncioViewModel extends ChangeNotifier {
  final FirebaseUtil _firebaseUtil = FirebaseUtil();

  List<Map<String, dynamic>> _annunci = [];

  List<Map<String, dynamic>> get annunci => _annunci;

  Future<void> creaAnnuncio(String userId, String materia) async {
    try {
      // Genera un ID univoco per l'annuncio
      String annuncioId = _firebaseUtil.createAnnuncioId();

      // Crea un annuncio con l'ID generato
      await _firebaseUtil.creaAnnuncio(userId, annuncioId, materia);
      notifyListeners();
    } catch (e) {
      print("Errore durante la creazione dell'annuncio: $e");
    }
  }
  Future<void> getAnnunciByUserId(String userId) async {
    try {
      _annunci = await _firebaseUtil.getAnnunciByUserId(userId);
      notifyListeners(); // Aggiorna la UI
    } catch (e) {
      print('Errore nel recupero degli annunci: $e');
    }
  }
  // Elimina un annuncio
  Future<void> eliminaAnnuncio(String annuncioId) async {
    await _firebaseUtil.eliminaAnnuncio(annuncioId);
    _annunci.removeWhere((annuncio) => annuncio['id'] == annuncioId);
    notifyListeners(); // Notifica alla UI che la lista è cambiata
  }
}