import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tutormatch/src/core/firebase_util.dart';
import '../models/prenotazione.dart';

class PrenotazioniViewModel extends ChangeNotifier {
  final FirebaseUtil _firebaseUtil = FirebaseUtil();
  List<Prenotazione> _prenotazioni = [];
  List<Prenotazione> get prenotazioni => _prenotazioni;

  // Variabile di stato per il caricamento
  bool isLoading = false;

  Future<void> caricaPrenotazioni(String userId, bool isTutor) async {
    isLoading = true;
    notifyListeners();

    try {
      List<Map<String, dynamic>> prenotazioniData = await _firebaseUtil.getPrenotazioniByUserId(userId, isTutor);

      _prenotazioni = prenotazioniData.map((data) {
        return Prenotazione(
          annuncioRef: (data['annuncioRef'] as DocumentReference).id,
          tutorRef: data['tutorRef'] as String,
          studenteRef: data['studenteRef'] as String,
          fasciaCalendarioRef: (data['fasciaCalendarioRef'] as DocumentReference).id,
        );
      }).toList();
    } catch (e) {
      print("Errore nel caricamento delle prenotazioni: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String> getMateriaFromAnnuncio(String annuncioId) async {
    try {
      DocumentSnapshot annuncioDoc = await _firebaseUtil.getAnnuncioById(annuncioId);
      return annuncioDoc.get('materia');
    } catch (e) {
      print("Errore nel recupero della materia: $e");
      throw e;
    }
  }

  Future<String> getNomeDaRef(String userRef) async {
    try {
      return await _firebaseUtil.getNomeDaRef(userRef);
    } catch (e) {
      print('Errore nel recupero del nome: $e');
      return 'Errore';
    }
  }

  // Metodo per eliminare una prenotazione confrontando la fasciaCalendarioRef
  Future<void> eliminaPrenotazione(String fasciaCalendarioRef) async {
    try {
      await _firebaseUtil.eliminaPrenotazioneByFascia(fasciaCalendarioRef);

      _prenotazioni.removeWhere((prenotazione) => prenotazione.fasciaCalendarioRef == fasciaCalendarioRef);

      notifyListeners();
    } catch (e) {
      print("Errore durante l'eliminazione della prenotazione: $e");
    }
  }
}
