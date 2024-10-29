import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tutormatch/src/core/firebase_util.dart';
import '../models/calendario.dart';
import '../models/prenotazione.dart';

// Definizione della classe PrenotazioniViewModel che estende ChangeNotifier
class PrenotazioniViewModel extends ChangeNotifier {
  final FirebaseUtil _firebaseUtil = FirebaseUtil();      // Utilità per interagire con Firebase
  List<Prenotazione> _prenotazioni = [];                  // Lista locale di prenotazioni
  List<Prenotazione> get prenotazioni => _prenotazioni;   // Getter per accedere alla lista di prenotazioni
  bool isLoading = false;                                 // Flag per indicare se i dati sono in caricamento
  StreamSubscription? _prenotazioniSubscription;          // Gestore per ascoltare in tempo reale le prenotazioni

  // Funzione per iniziare ad ascoltare le prenotazioni in tempo reale per un utente specifico
  void listenToPrenotazioni(String userId, bool ruolo) {
    _prenotazioniSubscription?.cancel(); // Cancella il listener precedente se esiste

    // Imposta un listener per la lista delle prenotazioni dell'utente con il ruolo specificato
    _prenotazioniSubscription = _firebaseUtil
        .getPrenotazioniStreamByUserId(userId, ruolo)
        .listen((snapshot) async {
      // Converte ogni documento snapshot in un oggetto Prenotazione
      _prenotazioni = snapshot.docs
          .map((doc) => Prenotazione.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Ordina le prenotazioni in base alla data e all'ora di inizio
      await ordinaPrenotazioniPerDataOra(_prenotazioni);
      notifyListeners(); // Notifica la UI dei cambiamenti
    }, onError: (error) {
      print("Errore nell'ascolto delle prenotazioni: $error"); // Stampa un messaggio di errore se necessario
    });
  }

  // Funzione per ordinare le prenotazioni per data e ora di inizio della fascia oraria
  Future<void> ordinaPrenotazioniPerDataOra(List<Prenotazione> prenotazioni) async {
    // Associa ogni prenotazione alla sua fascia oraria recuperata da Firebase
    final fasceOrarieMap = await Future.wait(prenotazioni.map((prenotazione) async {
      final fasciaOraria = await _firebaseUtil.getFasciaOraria(prenotazione.fasciaCalendarioRef); // Recupera la fascia oraria corrispondente alla prenotazione
      return {
        'prenotazione': prenotazione,
        'fasciaOraria': fasciaOraria,
      };
    }));

    // Ordina le prenotazioni per data e ora di inizio
    fasceOrarieMap.sort((a, b) {
      final Calendario fasciaA = a['fasciaOraria'] as Calendario;
      final Calendario fasciaB = b['fasciaOraria'] as Calendario;
      int dateComparison = fasciaA.data.compareTo(fasciaB.data); // Confronta le date
      if (dateComparison != 0) {
        return dateComparison; // Ordina per data
      } else {
        return fasciaA.oraInizio.compareTo(fasciaB.oraInizio); // Ordina per ora di inizio se le date sono uguali
      }
    });
    // Aggiorna la lista delle prenotazioni con l’ordine corretto
    _prenotazioni = fasceOrarieMap.map((item) => item['prenotazione'] as Prenotazione).toList();
  }

  // Metodo di pulizia che cancella il listener quando l'oggetto viene distrutto
  @override
  void dispose() {
    _prenotazioniSubscription?.cancel(); // Cancella il listener se è attivo
    _prenotazioniSubscription = null; // Imposta a null per consentire un nuovo listener in futuro
    super.dispose();
  }

  // Metodo per creare nuove prenotazioni utilizzando una funzione batch su Firebase
  Future<void> creaPrenotazioni(String userId, String tutorId, String annuncioId, List<String> fasceSelezionate) async {
    try {
      await FirebaseUtil().creaPrenotazioniBatch(userId, tutorId, annuncioId, fasceSelezionate); // Funzione batch per creare prenotazioni
    } catch (e) {
      print("Errore durante la creazione delle prenotazioni: $e"); // Gestisce eventuali errori
    }
  }

  // Metodo per ottenere la materia di un annuncio specifico in base all'ID dell'annuncio
  Future<String> getMateriaFromAnnuncio(String annuncioId) async {
    try {
      DocumentSnapshot annuncioDoc = await _firebaseUtil.getAnnuncioById(annuncioId); // Recupera l'annuncio dal database
      return annuncioDoc.get('materia'); // Ritorna la materia dell'annuncio
    } catch (e) {
      print("Errore nel recupero della materia: $e"); // Stampa un errore in caso di problemi
      throw e;
    }
  }

  // Metodo per ottenere il nome di un utente in base al riferimento del documento
  Future<String> getNomeDaRef(String userRef) async {
    try {
      return await _firebaseUtil.getNomeDaRef(userRef); // Ritorna il nome dell'utente
    } catch (e) {
      print('Errore nel recupero del nome: $e'); // Gestisce eventuali errori
      return 'Errore';
    }
  }

  // Metodo per eliminare una prenotazione e aggiornare lo stato nel calendario
  Future<void> eliminaPrenotazione(DocumentReference fasciaCalendarioRef, String tutorId) async {
    try {
      await _firebaseUtil.eliminaPrenotazioneByFascia(fasciaCalendarioRef, tutorId);
    } catch (e) {
      print("Errore durante l'eliminazione della prenotazione: $e");
    }
  }
}
