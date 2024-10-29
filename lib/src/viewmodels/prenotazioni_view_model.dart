import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tutormatch/src/core/firebase_util.dart';
import '../models/prenotazione.dart';

class PrenotazioniViewModel extends ChangeNotifier {
  final FirebaseUtil _firebaseUtil = FirebaseUtil();
  List<Prenotazione> _prenotazioni = [];
  List<Prenotazione> get prenotazioni => _prenotazioni;
  bool isLoading = false;
  StreamSubscription? _prenotazioniSubscription; // Per gestire il listener

  void listenToPrenotazioni(String userId, bool ruolo) {
    // Controlla se c'è già un listener attivo
    if (_prenotazioniSubscription != null) {
      print("Listener già attivo, non ne viene creato uno nuovo.");
      return; // Esce senza creare un nuovo listener
    }

    // Ottieni lo stream di prenotazioni filtrato per utente e ruolo
    _prenotazioniSubscription = _firebaseUtil
        .getPrenotazioniStreamByUserId(userId, ruolo)
        .listen((snapshot) {
      _prenotazioni = snapshot.docs
          .map((doc) => Prenotazione.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      notifyListeners(); // Notifica l'interfaccia che i dati sono cambiati
    }, onError: (error) {
      print("Errore nell'ascolto delle prenotazioni: $error");
    });
  }


  @override
  void dispose() {
    _prenotazioniSubscription?.cancel(); // Cancella il listener quando l'oggetto viene distrutto
    _prenotazioniSubscription = null; // Imposta a null per consentire la creazione di nuovi listener in futuro
    super.dispose();
  }



  Future<void> creaPrenotazioni(String userId, String tutorId, String annuncioId, List<String> fasceSelezionate) async {
    try {
      // Richiama la funzione nel FirebaseUtil e passa tutti i parametri necessari
      await FirebaseUtil().creaPrenotazioniBatch(userId, tutorId, annuncioId, fasceSelezionate);
    } catch (e) {
      print("Errore durante la creazione delle prenotazioni: $e");
      // Gestisci eventuali errori
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


  // Metodo per eliminare una prenotazione e aggiornare lo stato in Calendario
  Future<void> eliminaPrenotazione(DocumentReference fasciaCalendarioRef, String tutorId) async {
    try {
      // Chiama Firestore per eliminare la prenotazione
      await _firebaseUtil.eliminaPrenotazioneByFascia(fasciaCalendarioRef, tutorId);
    } catch (e) {
      print("Errore durante l'eliminazione della prenotazione: $e");
    }
  }


}