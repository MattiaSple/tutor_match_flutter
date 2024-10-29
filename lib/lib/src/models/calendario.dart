import 'package:cloud_firestore/cloud_firestore.dart';

class Calendario {
  final DocumentReference tutorRef;
  final DateTime data;
  final String oraInizio;
  final String oraFine;
  final bool statoPren;

  Calendario({
    required this.tutorRef,
    required this.data,
    required this.oraInizio,
    required this.oraFine,
    required this.statoPren,
  });

  // Metodo per creare un oggetto Calendario dai dati Firestore
  factory Calendario.fromFirestore(Map<String, dynamic> data) {
    return Calendario(
      tutorRef: data['tutorRef'] as DocumentReference,
      data: (data['data'] as Timestamp).toDate(),
      oraInizio: data['oraInizio'] as String,
      oraFine: data['oraFine'] as String,
      statoPren: data['statoPren'] as bool,
    );
  }

  // Metodo per convertire l'oggetto in mappa per salvare in Firestore
  Map<String, dynamic> toMap() {
    return {
      'tutorRef': tutorRef,
      'data': Timestamp.fromDate(DateTime(data.year, data.month, data.day,0,0,0,0,0)), // solo data
      'oraInizio': oraInizio,
      'oraFine': oraFine,
      'statoPren': statoPren,
    };
  }

}
