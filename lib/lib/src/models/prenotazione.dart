import 'package:cloud_firestore/cloud_firestore.dart';

class Prenotazione {
  final String studenteRef;
  final String tutorRef;
  final DocumentReference fasciaCalendarioRef;
  final DocumentReference annuncioRef;

  Prenotazione({
    required this.studenteRef,
    required this.tutorRef,
    required this.fasciaCalendarioRef,
    required this.annuncioRef,
  });

  // Metodo per convertire una Map in oggetto Prenotazione
  factory Prenotazione.fromMap(Map<String, dynamic> data) {
    return Prenotazione(
      studenteRef: data['studenteRef'] as String,
      tutorRef: data['tutorRef'] as String,
      fasciaCalendarioRef: data['fasciaCalendarioRef'] as DocumentReference,
      annuncioRef: data['annuncioRef'] as DocumentReference,
    );
  }
}
