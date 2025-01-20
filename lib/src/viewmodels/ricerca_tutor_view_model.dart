import 'package:cloud_firestore/cloud_firestore.dart'; // Per interagire con Firestore.
import 'package:flutter/material.dart'; // Per la gestione della UI con Flutter.
import 'package:tutormatch/src/core/firebase_util.dart'; // Utility per operazioni su Firebase.
import 'package:tutormatch/src/models/annuncio.dart'; // Modello per rappresentare gli annunci.
import 'package:tutormatch/src/models/utente.dart'; // Modello per rappresentare gli utenti.

class RicercaTutorViewModel extends ChangeNotifier {
  // Istanza di FirebaseUtil per interagire con il database Firebase.
  final FirebaseUtil _firebaseUtil = FirebaseUtil();

  // Lista degli annunci caricati.
  List<Annuncio> annunci = [];

  // Cache per memorizzare i dettagli dei tutor già caricati.
  Map<String, Utente> tutorDetailsCache = {};

  // Funzione per cercare gli annunci in base alla materia.
  Future<void> cercaAnnunciPerMateria(String materia) async {
    try {
      // Recupera gli annunci dalla materia specificata usando FirebaseUtil.
      List<Annuncio> fetchedAnnunci = await _firebaseUtil.getAnnunciByMateria(materia);

      // Aggiorna la lista locale degli annunci.
      annunci = fetchedAnnunci;

      // Notifica i listener che la lista degli annunci è cambiata.
      notifyListeners();
    } catch (e) {
      // Gestisce eventuali errori durante la ricerca.
      print('Errore durante la ricerca degli annunci: $e');
    }
  }

  // Funzione per ottenere i dettagli di un tutor da un riferimento a un documento Firestore.
  Future<Utente> getTutorFromAnnuncio(DocumentReference tutorRef) async {
    // Verifica se i dettagli del tutor sono già nella cache.
    if (tutorDetailsCache.containsKey(tutorRef.id)) {
      return tutorDetailsCache[tutorRef.id]!; // Restituisce i dettagli dalla cache.
    }

    try {
      // Recupera i dettagli del tutor utilizzando FirebaseUtil.
      Utente tutor = await _firebaseUtil.getTutorByDocumentReference(tutorRef);

      // Salva i dettagli del tutor nella cache.
      tutorDetailsCache[tutorRef.id] = tutor;

      // Restituisce i dettagli del tutor.
      return tutor;
    } catch (e) {
      // Gestisce eventuali errori durante il caricamento dei dettagli del tutor.
      throw Exception('Errore nel caricamento del tutor: $e');
    }
  }

  // Funzione per cercare annunci in base alla materia e alla città.
  Future<void> cercaAnnunciPerCittaEMateria(String citta, String materia) async {
    try {
      // Query Firestore per recuperare gli annunci della materia specificata.
      QuerySnapshot annuncioSnapshot = await FirebaseFirestore.instance
          .collection('annunci')
          .where('materia', isEqualTo: materia)
          .get();

      // Filtra gli annunci in base alla residenza del tutor.
      List<Annuncio> filtrati = [];
      for (var doc in annuncioSnapshot.docs) {
        // Crea un oggetto Annuncio dal documento Firestore.
        Annuncio annuncio = Annuncio.fromMap(doc.data() as Map<String, dynamic>, doc.id);

        // Recupera i dettagli del tutor associato all'annuncio.
        Utente tutor = await _firebaseUtil.getTutorByDocumentReference(annuncio.tutorRef);

        // Aggiunge l'annuncio alla lista se il tutor risiede nella città specificata.
        if (tutor.residenza.toLowerCase().contains(citta.toLowerCase())) {
          filtrati.add(annuncio);
        }
      }

      // Aggiorna la lista locale degli annunci con i risultati filtrati.
      annunci = filtrati;

      // Notifica i listener che la lista degli annunci è cambiata.
      notifyListeners();
    } catch (e) {
      // Gestisce eventuali errori durante la ricerca per città e materia.
      print("Errore nella ricerca per città e materia: $e");
    }
  }
}
