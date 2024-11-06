import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tutormatch/src/models/calendario.dart';
import 'package:tutormatch/src/core/firebase_util.dart';

class CalendarioViewModel extends ChangeNotifier {
  final FirebaseUtil _firebaseUtil = FirebaseUtil();
  List<Calendario> fasceOrarie = [];
  String? message;
  StreamSubscription? _fasceOrarieSubscription; // Subscription per ascoltare i cambiamenti in tempo reale
  ValueNotifier<String?> errorNotifier = ValueNotifier(null); // Notificatore per i messaggi di errore

  void listenToFasceOrarie(String tutorId, bool ruolo) {
    // Se esiste un listener attivo, cancellalo prima di crearne uno nuovo
    _fasceOrarieSubscription?.cancel();

    // Crea un nuovo listener per le fasce orarie in base al nuovo tutorId
    _fasceOrarieSubscription = _firebaseUtil
        .getFasceOrarieStreamByTutorId(tutorId, ruolo)
        .listen((snapshot) {
      print("Listener attivato per un aggiornamento nel database.");

      // Aggiorna la lista delle fasce orarie
      fasceOrarie = snapshot.docs
          .map((doc) => Calendario.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();

      ordinaFasceOrarie(); // Ordina le fasce orarie dopo l'aggiornamento
      notifyListeners(); // Notifica la UI dei cambiamenti
    }, onError: (error) {
      print("Errore nell'ascolto delle fasce orarie: $error");
      errorNotifier.value = "Errore nel caricamento delle fasce orarie.";
      notifyListeners();
    });
  }


  @override
  void dispose() {
    _fasceOrarieSubscription?.cancel(); // Cancella il listener quando l'oggetto viene distrutto
    _fasceOrarieSubscription = null; // Imposta a null per consentire la creazione di nuovi listener in futuro
    super.dispose();
  }

  // funzione per ottenere data, oraInizio e oraFine per una fascia specifica
  Future<Map<String, String>> getOrarioFascia(DocumentReference fasciaCalendarioRef) async {
    try {
      Calendario fascia = await _firebaseUtil.getFasciaOraria(fasciaCalendarioRef);
      return {
        'data': '${fascia.data.toLocal().toString().split(' ')[0]}', // Mostra solo la data
        'oraInizio': fascia.oraInizio,
        'oraFine': fascia.oraFine,
      };
    } catch (e) {
      print("Errore nel recupero dell'orario della fascia: $e");
      return {
        'data': 'N/A',
        'oraInizio': 'N/A',
        'oraFine': 'N/A',
      };
    }
  }


  Future<void> aggiungiFasciaOraria(
      String tutorId, DateTime data, TimeOfDay oraInizio, TimeOfDay oraFine) async {

    // Ottieni il DocumentReference per il tutorId dal FirebaseUtil
    final DocumentReference? tutorRef = await _firebaseUtil.getTutorReference(tutorId);

    // Controlla se il tutorRef è null (se il tutor non esiste)
    if (tutorRef == null) {
      errorNotifier.value = 'Tutor non trovato, impossibile aggiungere la fascia oraria.';
      return;
    }

    // Formatta l'ora di inizio e fine in formato "HH:mm"
    final String formattedOraInizio = formatTimeOfDay(oraInizio);
    final String formattedOraFine = formatTimeOfDay(oraFine);

    // Crea la nuova fascia oraria usando il modello Calendario
    final nuovaFascia = Calendario(
      tutorRef: tutorRef, // Usa il DocumentReference recuperato
      data: DateTime(data.year, data.month, data.day, 0, 0, 0, 0, 0), // Solo la data senza ore
      oraInizio: formattedOraInizio,
      oraFine: formattedOraFine,
      statoPren: false,
    );

    // Controllo di sovrapposizione prima di fare la chiamata al database
    bool sovrapposizione = fasceOrarie.any((fascia) =>
    _compareDateOnly(fascia.data, nuovaFascia.data) == 0 && // Controlla se la data è la stessa
        ((fascia.oraInizio.compareTo(nuovaFascia.oraInizio) >= 0 &&
            fascia.oraInizio.compareTo(nuovaFascia.oraFine) < 0) ||
            (fascia.oraFine.compareTo(nuovaFascia.oraInizio) > 0 &&
                fascia.oraFine.compareTo(nuovaFascia.oraFine) <= 0)));

    if (sovrapposizione) {
      // Se c'è sovrapposizione, ritorna e non aggiunge la fascia
      errorNotifier.value = 'Le fasce orarie non possono sovrapporsi.';
      return;
    }

    // Prova a inserire la nuova fascia nel database
    try {
      bool success = await _firebaseUtil.aggiungiFasciaOraria(nuovaFascia);
      print("GGGGGGGGGGGGGGGGGGGGGGGGGGGG");
      if (success) {
        ordinaFasceOrarie(); // Ordina la lista dopo l'aggiunta
      } else {
        errorNotifier.value = 'Errore nell\'aggiunta della fascia';
      }
    } catch (e) {
      errorNotifier.value = 'Errore durante l\'aggiunta della fascia oraria: ${e.toString()}';
    }
  }


  // Funzione per eliminare una fascia oraria
  Future<void> eliminaFasciaOraria(String tutorId, DateTime data, String oraInizio) async {
    bool success = await _firebaseUtil.eliminaFasciaOraria(tutorId, data, oraInizio);
    if (!success) {
      errorNotifier.value = 'Errore nell\'eliminazione della fascia oraria';
    }
  }

  // Funzione di ordinamento delle fasce orarie
  void ordinaFasceOrarie() {
    fasceOrarie.sort((a, b) {
      int dateComparison = _compareDateOnly(a.data, b.data);
      if (dateComparison != 0) {
        return dateComparison;
      } else {
        return a.oraInizio.compareTo(b.oraInizio);
      }
    });
  }

  // Funzione per confrontare solo anno, mese, giorno delle date
  int _compareDateOnly(DateTime a, DateTime b) {
    DateTime dateA = DateTime(a.year, a.month, a.day);
    DateTime dateB = DateTime(b.year, b.month, b.day);
    return dateA.compareTo(dateB);
  }

  // Funzione di supporto per formattare TimeOfDay in "HH:mm"
  String formatTimeOfDay(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}
