import 'package:cloud_firestore/cloud_firestore.dart';

class Annuncio {
  final String id;
  final String materia;
  final DocumentReference tutorRef; // Cambiato da String a DocumentReference

  Annuncio({
    required this.id,
    required this.materia,
    required this.tutorRef, // Cambiato da String a DocumentReference
  });

  // Metodo per creare un oggetto Annuncio da una mappa di Firestore
  factory Annuncio.fromMap(Map<String, dynamic> data, String documentId) {
    return Annuncio(
      id: documentId,
      materia: data['materia'] as String,
      tutorRef: data['tutor'] as DocumentReference, // Recupera il DocumentReference
    );
  }
}