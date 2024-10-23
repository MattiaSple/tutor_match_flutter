class Annuncio {
  final String id;
  final String materia;
  final String tutor;

  Annuncio({
    required this.id,
    required this.materia,
    required this.tutor,
  });

  // Metodo per convertire una Map in oggetto Annuncio
  factory Annuncio.fromMap(Map<String, dynamic> data, String documentId) {
    return Annuncio(
      id: documentId,
      materia: data['materia'] as String,
      tutor: data['tutor'] as String,
    );
  }
}