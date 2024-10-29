import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tutormatch/src/core/firebase_util.dart';
import 'package:tutormatch/src/models/annuncio.dart';
import 'package:tutormatch/src/models/utente.dart';

class RicercaTutorViewModel extends ChangeNotifier {
  final FirebaseUtil _firebaseUtil = FirebaseUtil();
  List<Annuncio> annunci = [];
  Map<String, Utente> tutorDetailsCache = {}; // Cache per non ricaricare i tutor già caricati

  // Funzione per cercare gli annunci per materia
  Future<void> cercaAnnunciPerMateria(String materia) async {
    try {
      // Usa FirebaseUtil per recuperare gli annunci
      List<Annuncio> fetchedAnnunci = await _firebaseUtil.getAnnunciByMateria(materia);
      annunci = fetchedAnnunci;
      notifyListeners();
    } catch (e) {
      print('Errore durante la ricerca degli annunci: $e');
    }
  }

  // Funzione per ottenere i dettagli del tutor usando il DocumentReference
  Future<Utente> getTutorFromAnnuncio(DocumentReference tutorRef) async {
    if (tutorDetailsCache.containsKey(tutorRef.id)) {
      return tutorDetailsCache[tutorRef.id]!; // Usa la cache se disponibile
    }

    try {
      // Chiama FirebaseUtil per ottenere i dettagli del tutor
      Utente tutor = await _firebaseUtil.getTutorByDocumentReference(tutorRef);
      tutorDetailsCache[tutorRef.id] = tutor; // Salva nella cache
      return tutor;
    } catch (e) {
      throw Exception('Errore nel caricamento del tutor: $e');
    }
  }
}
