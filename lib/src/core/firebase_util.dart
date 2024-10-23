import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUtil {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Recupera il ruolo dell'utente dal database
  Future<bool> getUserRole(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('utenti').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.get('ruolo'); // true = tutor, false = studente
      } else {
        throw Exception('Utente non trovato');
      }
    } catch (e) {
      print("Errore nel recupero del ruolo: $e");
      throw e;
    }
  }
// Funzione per generare un ID univoco per l'annuncio
  String createAnnuncioId() {
    return _firestore.collection('annunci').doc().id; // Genera un ID univoco
  }

  // Funzione per creare un annuncio con l'ID generato
  Future<void> creaAnnuncio(String userId, String annuncioId, String materia) async {
    try {
      DocumentReference tutorRef = _firestore.collection('utenti').doc(userId); // Salva il DocumentReference

      await _firestore.collection('annunci').doc(annuncioId).set({
        'id': annuncioId,
        'tutor': tutorRef, // Salva direttamente il DocumentReference
        'materia': materia,
      });
    } catch (e) {
      print("Errore durante la creazione dell'annuncio: $e");
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getAnnunciByUserId(String userId) async {
    try {
      DocumentReference tutorRef = _firestore.collection('utenti').doc(userId); // Riferimento all'utente

      QuerySnapshot snapshot = await _firestore
          .collection('annunci')
          .where('tutor', isEqualTo: tutorRef) // Confronto con il DocumentReference
          .get();

      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Errore nel recupero degli annunci: $e');
      throw e;
    }
  }
  // Funzione per recuperare un annuncio tramite il suo ID
  Future<DocumentSnapshot> getAnnuncioById(String annuncioId) async {
    try {
      // Recupera il documento tramite il solo ID
      DocumentSnapshot annuncioDoc = await _firestore.collection('annunci').doc(annuncioId).get();
      return annuncioDoc;
    } catch (e) {
      print("Errore nel recupero dell'annuncio: $e");
      throw e;
    }
  }
  // Elimina un annuncio
  Future<void> eliminaAnnuncio(String annuncioId) async {
    try {
      await _firestore.collection('annunci').doc(annuncioId).delete();
    } catch (e) {
      throw Exception('Errore durante l\'eliminazione dell\'annuncio: $e');
    }
  }

// Recupera tutte le prenotazioni di un utente
  Future<List<Map<String, dynamic>>> getPrenotazioniByUserId(String userId, bool isTutor) async {
    try {
      Query query = _firestore.collection('prenotazioni');

      // Se l'utente è un tutor, cerchiamo dove tutorRef corrisponde all'userId
      if (isTutor) {
        query = query.where('tutorRef', isEqualTo: userId);
      } else {
        // Se l'utente è uno studente, cerchiamo dove studenteRef corrisponde all'userId
        query = query.where('studenteRef', isEqualTo: userId);
      }

      // Eseguiamo la query con il filtro corretto
      QuerySnapshot snapshot = await query.get();

      // Convertiamo i documenti in una lista di mappe
      List<Map<String, dynamic>> result = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      return result;
    } catch (e) {
      print("Errore nel recupero delle prenotazioni: $e");
      throw e;
    }
  }


  // Recupera il nome di un utente da una referenza
  Future<String> getNomeDaRef(String userRef) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('utenti').doc(userRef).get();
      return "${userDoc.get('nome')} ${userDoc.get('cognome')}";
    } catch (e) {
      print("Errore nel recupero del nome: $e");
      throw e;
    }
  }

// Elimina una prenotazione tramite fasciaCalendarioRef
  Future<void> eliminaPrenotazioneByFascia(String fasciaCalendarioRef) async {
    try {
      // Crea il riferimento del documento fasciaCalendarioRef
      DocumentReference calendarioRef = _firestore.doc('calendario/$fasciaCalendarioRef');

      // Cerca la prenotazione che ha quella fasciaCalendarioRef
      QuerySnapshot snapshot = await _firestore
          .collection('prenotazioni')
          .where('fasciaCalendarioRef', isEqualTo: calendarioRef) // Confronta il DocumentReference
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Elimina solo la prima prenotazione trovata con quella fasciaCalendarioRef
        await snapshot.docs.first.reference.delete();
      } else {
        print("Nessuna prenotazione trovata con annuncioRef: $fasciaCalendarioRef");
      }
    } catch (e) {
      print("Errore durante l'eliminazione della prenotazione con annuncioRef: $e");
      throw e;
    }
  }
  // Recupera i dati dell'utente dal database
  Future<DocumentSnapshot> getUserById(String userId) async {
    try {
      return await _firestore.collection('utenti').doc(userId).get();
    } catch (e) {
      print('Errore nel recupero dell\'utente: $e');
      throw e;
    }
  }

  // Aggiorna i dati del profilo dell'utente nel database
  Future<void> aggiornaProfilo(String userId, String nome, String cognome) async {
    try {
      await _firestore.collection('utenti').doc(userId).update({
        'nome': nome,
        'cognome': cognome,
      });
    } catch (e) {
      print('Errore durante l\'aggiornamento del profilo: $e');
      throw e;
    }
  }
}
