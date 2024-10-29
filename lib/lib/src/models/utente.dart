class Utente {
  String nome;
  String cognome;
  String email;
  String userId;
  bool ruolo; // true = tutor, false = studente
  List<String> tutorDaValutare; // Lista di ID dei tutor da valutare
  List<int> feedback; // Lista di feedback numerici
  String residenza; // Aggiunto il campo residenza

  Utente({
    required this.nome,
    required this.cognome,
    required this.email,
    required this.userId,
    required this.ruolo,
    required this.tutorDaValutare,
    required this.feedback,
    required this.residenza, // Aggiunto nel costruttore
  });

  // Factory method per creare un Utente da un documento Firestore
  factory Utente.fromMap(Map<String, dynamic> data, String userId) {
    return Utente(
      nome: data['nome'] ?? '',
      cognome: data['cognome'] ?? '',
      email: data['email'] ?? '',
      userId: userId, // Lo userId non è presente nel documento stesso, lo passiamo dall'esterno
      ruolo: data['ruolo'] ?? false,
      tutorDaValutare: List<String>.from(data['tutorDaValutare'] ?? []),
      feedback: List<int>.from(data['feedback'] ?? []), // Cambiamo a List<int>
      residenza: data['residenza'] ?? 'Non specificata', // Recupera la residenza
    );
  }

  // Converte un Utente in una mappa per salvare su Firestore
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'cognome': cognome,
      'email': email,
      'ruolo': ruolo,
      'tutorDaValutare': tutorDaValutare,
      'feedback': feedback, // Rimane List<int> per salvare correttamente
      'residenza': residenza, // Aggiungi il campo residenza
    };
  }
}

