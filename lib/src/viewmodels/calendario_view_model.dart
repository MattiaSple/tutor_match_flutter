import 'dart:async'; // Per gestire stream e sottoscrizioni.
import 'package:cloud_firestore/cloud_firestore.dart'; // Per interagire con il database Firestore.
import 'package:flutter/material.dart'; // Per la gestione della UI con Flutter.
import 'package:tutormatch/src/models/calendario.dart'; // Modello Calendario per rappresentare le fasce orarie.
import 'package:tutormatch/src/core/firebase_util.dart'; // Utility per operazioni su Firebase.

class CalendarioViewModel extends ChangeNotifier {
  // Istanza di FirebaseUtil per interagire con il database.
  final FirebaseUtil _firebaseUtil = FirebaseUtil();

  // Lista delle fasce orarie.
  List<Calendario> fasceOrarie = [];

  // Messaggio per la gestione degli errori.
  String? message;

  // Stato di caricamento.
  bool isLoading = false;

  // Subscription per ascoltare i cambiamenti in tempo reale nel database.
  StreamSubscription? _fasceOrarieSubscription;

  // Notificatore per i messaggi di errore.
  ValueNotifier<String?> errorNotifier = ValueNotifier(null);

  // Ascolta le fasce orarie di un tutor specifico.
  void listenToFasceOrarie(String tutorId, bool ruolo) {
    // Annulla un eventuale listener esistente.
    _fasceOrarieSubscription?.cancel();

    // Crea un nuovo listener per le fasce orarie.
    _fasceOrarieSubscription = _firebaseUtil
        .getFasceOrarieStreamByTutorId(tutorId, ruolo)
        .listen((snapshot) {
      // Aggiorna la lista delle fasce orarie dal database.
      fasceOrarie = snapshot.docs
          .map((doc) => Calendario.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();

      // Ordina le fasce orarie e notifica i cambiamenti.
      ordinaFasceOrarie();
      notifyListeners();
    }, onError: (error) {
      // Gestione degli errori.
      errorNotifier.value = "Errore nel caricamento delle fasce orarie.";
      notifyListeners();
    });
  }

  // Rimuove il listener attivo durante la distruzione dell'oggetto.
  @override
  void dispose() {
    _fasceOrarieSubscription?.cancel();
    _fasceOrarieSubscription = null;
    super.dispose();
  }

  // Recupera i dettagli di una fascia oraria specifica.
  Future<Map<String, String>> getOrarioFascia(DocumentReference fasciaCalendarioRef) async {
    try {
      // Ottiene i dettagli della fascia oraria.
      Calendario fascia = await _firebaseUtil.getFasciaOraria(fasciaCalendarioRef);
      return {
        'data': '${fascia.data.toLocal().toString().split(' ')[0]}',
        'oraInizio': fascia.oraInizio,
        'oraFine': fascia.oraFine,
      };
    } catch (e) {
      // Restituisce valori predefiniti in caso di errore.
      return {
        'data': 'N/A',
        'oraInizio': 'N/A',
        'oraFine': 'N/A',
      };
    }
  }

  // Aggiunge una nuova fascia oraria.
  Future<void> aggiungiFasciaOraria(
      String tutorId, DateTime data, TimeOfDay oraInizio, TimeOfDay oraFine) async {
    if (isLoading) return; // Evita richieste duplicate.

    isLoading = true;
    notifyListeners();

    // Ottiene il riferimento al tutor dal database.
    final DocumentReference tutorRef =
    (await _firebaseUtil.getTutorReference(tutorId))!;

    // Converte l'ora in formato "HH:mm".
    final String formattedOraInizio = formatTimeOfDay(oraInizio);
    final String formattedOraFine = formatTimeOfDay(oraFine);

    // Crea la nuova fascia oraria.
    final nuovaFascia = Calendario(
      tutorRef: tutorRef,
      data: DateTime(data.year, data.month, data.day),
      oraInizio: formattedOraInizio,
      oraFine: formattedOraFine,
      statoPren: false,
    );

    try {
      // Aggiunge la fascia al database.
      bool success = await _firebaseUtil.aggiungiFasciaOraria(nuovaFascia);
      if (success) {
        ordinaFasceOrarie(); // Ordina le fasce dopo l'aggiunta.
      } else {
        errorNotifier.value = 'Errore nell\'aggiunta della fascia';
      }
    } catch (e) {
      // Gestisce gli errori durante l'aggiunta.
      errorNotifier.value = 'Errore durante l\'aggiunta della fascia oraria: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Elimina una fascia oraria specifica.
  Future<void> eliminaFasciaOraria(String tutorId, DateTime data, String oraInizio) async {
    bool success = await _firebaseUtil.eliminaFasciaOraria(tutorId, data, oraInizio);
    if (!success) {
      errorNotifier.value = 'Errore nell\'eliminazione della fascia oraria';
    }
  }

  // Ordina le fasce orarie per data e ora di inizio.
  void ordinaFasceOrarie() {
    fasceOrarie.sort((a, b) {
      int dateComparison = compareDateOnly(a.data, b.data);
      return dateComparison != 0 ? dateComparison : a.oraInizio.compareTo(b.oraInizio);
    });
  }

  // Confronta due date considerando solo anno, mese e giorno.
  int compareDateOnly(DateTime a, DateTime b) {
    DateTime dateA = DateTime(a.year, a.month, a.day);
    DateTime dateB = DateTime(b.year, b.month, b.day);
    return dateA.compareTo(dateB);
  }

  // Converte un oggetto TimeOfDay in una stringa "HH:mm".
  String formatTimeOfDay(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}
