import 'dart:async'; // Per gestire stream e sottoscrizioni.
import 'package:cloud_firestore/cloud_firestore.dart'; // Per interagire con il database Firestore.
import 'package:flutter/material.dart'; // Per la gestione della UI con Flutter.
import 'package:tutormatch/src/core/firebase_util.dart'; // Utility per operazioni su Firebase.
import '../models/calendario.dart'; // Modello per rappresentare le fasce orarie del calendario.
import '../models/prenotazione.dart'; // Modello per rappresentare le prenotazioni.

class PrenotazioniViewModel extends ChangeNotifier {
  // Istanza di FirebaseUtil per interagire con il database Firebase.
  final FirebaseUtil _firebaseUtil = FirebaseUtil();

  // Lista locale delle prenotazioni.
  List<Prenotazione> _prenotazioni = [];

  // Getter per accedere alle prenotazioni.
  List<Prenotazione> get prenotazioni => _prenotazioni;

  // Stato di caricamento per evitare chiamate simultanee.
  bool isLoading = false;

  // Gestore per ascoltare in tempo reale le prenotazioni.
  StreamSubscription? _prenotazioniSubscription;

  // Inizia a monitorare le prenotazioni in tempo reale per un utente specifico.
  void listenToPrenotazioni(String userId, bool ruolo) {
    _prenotazioniSubscription?.cancel(); // Cancella un eventuale listener precedente.

    // Imposta un listener per la lista di prenotazioni dell'utente.
    _prenotazioniSubscription = _firebaseUtil
        .getPrenotazioniStreamByUserId(userId, ruolo)
        .listen((snapshot) async {
      // Converte ogni documento snapshot in un oggetto Prenotazione.
      _prenotazioni = snapshot.docs
          .map((doc) => Prenotazione.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Ordina le prenotazioni in base alla data e all'ora di inizio.
      await ordinaPrenotazioniPerDataOra(_prenotazioni);

      // Notifica la UI che le prenotazioni sono state aggiornate.
      notifyListeners();
    }, onError: (error) {
      // Stampa un messaggio di errore in caso di problemi.
      print("Errore nell'ascolto delle prenotazioni: $error");
    });
  }

  // Ordina le prenotazioni in base alla data e all'ora di inizio.
  Future<void> ordinaPrenotazioniPerDataOra(List<Prenotazione> prenotazioni) async {
    // Associa ogni prenotazione alla sua fascia oraria recuperata da Firebase.
    final fasceOrarieMap = await Future.wait(prenotazioni.map((prenotazione) async {
      final fasciaOraria = await _firebaseUtil.getFasciaOraria(prenotazione.fasciaCalendarioRef);
      return {
        'prenotazione': prenotazione,
        'fasciaOraria': fasciaOraria,
      };
    }));

    // Ordina le fasce orarie per data e ora di inizio.
    fasceOrarieMap.sort((a, b) {
      final Calendario fasciaA = a['fasciaOraria'] as Calendario;
      final Calendario fasciaB = b['fasciaOraria'] as Calendario;
      int dateComparison = fasciaA.data.compareTo(fasciaB.data);
      if (dateComparison != 0) {
        return dateComparison; // Ordina per data.
      } else {
        return fasciaA.oraInizio.compareTo(fasciaB.oraInizio); // Ordina per ora se le date sono uguali.
      }
    });

    // Aggiorna la lista delle prenotazioni con l'ordine corretto.
    _prenotazioni = fasceOrarieMap.map((item) => item['prenotazione'] as Prenotazione).toList();
  }

  // Cancella il listener attivo quando l'oggetto viene distrutto.
  @override
  void dispose() {
    _prenotazioniSubscription?.cancel(); // Cancella il listener se attivo.
    _prenotazioniSubscription = null; // Imposta a null per consentire un nuovo listener.
    super.dispose();
  }

  // Crea nuove prenotazioni utilizzando una funzione batch su Firebase.
  Future<void> creaPrenotazioni(String userId, String tutorId, String annuncioId, List<String> fasceSelezionate) async {
    try {
      // Utilizza una funzione batch per creare più prenotazioni contemporaneamente.
      await FirebaseUtil().creaPrenotazioniBatch(userId, tutorId, annuncioId, fasceSelezionate);
    } catch (e) {
      // Gestisce eventuali errori durante la creazione.
      print("Errore durante la creazione delle prenotazioni: $e");
    }
  }

  // Recupera la materia di un annuncio specifico in base al suo ID.
  Future<String> getMateriaFromAnnuncio(String annuncioId) async {
    try {
      // Ottiene il documento dell'annuncio da Firebase.
      DocumentSnapshot annuncioDoc = await _firebaseUtil.getAnnuncioById(annuncioId);

      // Restituisce la materia associata all'annuncio.
      return annuncioDoc.get('materia');
    } catch (e) {
      // Gestisce eventuali errori durante il recupero.
      print("Errore nel recupero della materia: $e");
      throw e;
    }
  }

  // Recupera il nome di un utente utilizzando il riferimento al documento.
  Future<String> getNomeDaRef(String userRef) async {
    try {
      // Restituisce il nome associato al riferimento.
      return await _firebaseUtil.getNomeDaRef(userRef);
    } catch (e) {
      // Gestisce eventuali errori durante il recupero del nome.
      print('Errore nel recupero del nome: $e');
      return 'Errore';
    }
  }

  // Elimina una prenotazione e aggiorna lo stato nel calendario.
  Future<void> eliminaPrenotazione(DocumentReference fasciaCalendarioRef, String tutorId) async {
    try {
      // Elimina la prenotazione associata alla fascia oraria.
      await _firebaseUtil.eliminaPrenotazioneByFascia(fasciaCalendarioRef, tutorId);
    } catch (e) {
      // Gestisce eventuali errori durante l'eliminazione.
      print("Errore durante l'eliminazione della prenotazione: $e");
    }
  }
}
