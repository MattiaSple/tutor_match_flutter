import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/annuncio.dart';
import '../models/calendario.dart';
import '../models/utente.dart';

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

  // Metodo per ottenere uno stream delle prenotazioni in tempo reale in base a userId e ruolo
  Stream<QuerySnapshot> getPrenotazioniStreamByUserId(String userId, bool ruolo) {
    return _firestore
        .collection('prenotazioni')
        .where(ruolo ? 'tutorRef' : 'studenteRef', isEqualTo: userId)
        .snapshots();
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
  // Aggiungi il feedback al profilo del tutor
  Future<void> aggiungiFeedback(String tutorId, int feedback) async {
    try {
      DocumentReference tutorRef = _firestore.collection('utenti').doc(tutorId);

      await tutorRef.update({
        'feedback': FieldValue.arrayUnion([feedback]) // Aggiungi il feedback alla lista
      });
    } catch (e) {
      print('Errore durante l\'aggiunta del feedback: $e');
      throw e;
    }
  }

  // Aggiorna la lista tutorDaValutare per l'utente
  Future<void> aggiornaTutorDaValutare(String userId, List<String> tutorDaValutareAggiornata) async {
    try {
      DocumentReference userRef = _firestore.collection('utenti').doc(userId);

      // Aggiorna il campo tutorDaValutare
      await userRef.update({
        'tutorDaValutare': tutorDaValutareAggiornata,
      });
    } catch (e) {
      print('Errore durante l\'aggiornamento di tutorDaValutare: $e');
      throw e;
    }
  }
  // Recupera l'email di un utente tramite userId
  Future<String> getEmailByUserId(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('utenti').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        return userDoc.get('email'); // Recupera l'email
      } else {
        throw Exception('Utente non trovato');
      }
    } catch (e) {
      print("Errore nel recupero dell'email: $e");
      throw e;
    }
  }

  // Funzione per caricare le fasce orarie
  Future<List<Calendario>> caricaFasceOrarie(String tutorId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('calendario')
          .where('tutorRef', isEqualTo: _firestore.doc('utenti/$tutorId'))
          .get();

      // Mappa i documenti Firestore nella lista di fasce orarie
      return snapshot.docs.map((doc) {
        return Calendario.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      // Log dell'errore e ritorna una lista vuota
      print('Errore nel caricamento delle fasce orarie: ${e.toString()}');
      return [];
    }
  }

  // Carica solo le fasce orarie disponibili di un tutor (per gli studenti)
  Future<List<Calendario>> caricaFasceOrarieDisponibili(String tutorId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('calendario')
          .where('tutorRef', isEqualTo: _firestore.doc('utenti/$tutorId'))
          .where('statoPren', isEqualTo: false) // Filtra solo le fasce disponibili
          .get();

      return snapshot.docs.map((doc) {
        return Calendario.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Errore nel caricamento delle fasce orarie disponibili: ${e.toString()}');
      return [];
    }
  }


  // Funzione per aggiungere una fascia oraria
  Future<bool> aggiungiFasciaOraria(Calendario nuovaFascia) async {
    try {
      await _firestore.collection('calendario').add(nuovaFascia.toMap());
      return true;  // Ritorna true se l'operazione ha successo
    } catch (e) {
      // Log dell'errore
      print('Errore nell\'aggiunta della fascia: ${e.toString()}');
      return false;  // Ritorna false in caso di errore
    }
  }

  // Funzione per eliminare una fascia oraria
  Future<bool> eliminaFasciaOraria(String tutorId, DateTime data, String oraInizio) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('calendario')
          .where('tutorRef', isEqualTo: _firestore.doc('utenti/$tutorId'))
          .where('data', isEqualTo: Timestamp.fromDate(data))
          .where('oraInizio', isEqualTo: oraInizio)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      return true;  // Ritorna true se l'operazione ha successo
    } catch (e) {
      // Log dell'errore
      print('Errore nell\'eliminazione della fascia oraria: ${e.toString()}');
      return false;  // Ritorna false in caso di errore
    }
  }




// Funzione per ottenere il DocumentReference per un tutorId
  Future<DocumentReference?> getTutorReference(String tutorId) async {
    try {
      // Recupera il documento del tutor con l'ID fornito
      DocumentReference tutorRef = _firestore.collection('utenti').doc(tutorId);

      // Controlla se il documento esiste effettivamente
      DocumentSnapshot tutorSnapshot = await tutorRef.get();
      if (tutorSnapshot.exists) {
        return tutorRef; // Ritorna il riferimento del documento
      } else {
        print("Tutor non trovato per l'ID $tutorId");
        return null; // Ritorna null se il tutor non esiste
      }
    } catch (e) {
      // Gestisci eventuali errori
      print('Errore nel recupero del DocumentReference: ${e.toString()}');
      return null;
    }
  }



// Funzione per ottenere annunci in base alla materia
  Future<List<Annuncio>> getAnnunciByMateria(String materia) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('annunci')
          .where('materia', isEqualTo: materia)
          .get();

      return snapshot.docs.map((doc) {
        return Annuncio.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Errore durante il recupero degli annunci: $e');
    }
  }

  // Funzione per ottenere i dettagli del tutor
  Future<Utente> getTutorById(String tutorId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('utenti').doc(tutorId).get();

      if (doc.exists) {
        return Utente.fromMap(doc.data() as Map<String, dynamic>, tutorId);
      } else {
        throw Exception('Il tutor non esiste');
      }
    } catch (e) {
      throw Exception('Errore durante il recupero del tutor: $e');
    }
  }


  // Funzione per ottenere i dettagli del tutor usando il DocumentReference
  Future<Utente> getTutorByDocumentReference(DocumentReference tutorRef) async {
    try {
      DocumentSnapshot doc = await tutorRef.get(); // Recupera il documento tramite il DocumentReference

      if (doc.exists) {
        return Utente.fromMap(doc.data() as Map<String, dynamic>, tutorRef.id); // Crea l'oggetto Utente
      } else {
        throw Exception('Il tutor non esiste');
      }
    } catch (e) {
      throw Exception('Errore durante il recupero del tutor: $e');
    }
  }

  Future<void> creaPrenotazioniBatch(String userId, String tutorId, String annuncioId, List<String> fasceSelezionate) async {
    WriteBatch batch = _firestore.batch();

    for (String fasciaIdentifier in fasceSelezionate) {
      // Spezza l'identificatore in data e ora di inizio
      final parts = fasciaIdentifier.split('_');
      DateTime data = DateTime.parse(parts[0]);
      String oraInizio = parts[1];

      // Cerca la fascia nel calendario usando data e ora di inizio
      QuerySnapshot querySnapshot = await _firestore
          .collection('calendario')
          .where('tutorRef', isEqualTo: _firestore.doc('utenti/$tutorId'))
          .where('data', isEqualTo: Timestamp.fromDate(data))
          .where('oraInizio', isEqualTo: oraInizio)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Riferimento alla fascia trovata
        DocumentReference fasciaRef = querySnapshot.docs.first.reference;

        // Aggiunge la prenotazione alla batch
        DocumentReference prenotazioneRef = _firestore.collection('prenotazioni').doc();
        batch.set(prenotazioneRef, {
          'studenteRef': userId,
          'tutorRef': tutorId,
          'fasciaCalendarioRef': fasciaRef,
          'annuncioRef': _firestore.doc('annunci/$annuncioId'),
        });

        // Aggiorna lo stato della fascia oraria come prenotata
        batch.update(fasciaRef, {'statoPren': true});
      }
    }

    // Esegui il batch
    await batch.commit();
  }


  // Funzione per recuperare una fascia oraria specifica dal suo riferimento
  Future<Calendario> getFasciaOraria(String fasciaCalendarioRef) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('calendario').doc(fasciaCalendarioRef).get();
      return Calendario.fromFirestore(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print("Errore nel recupero della fascia oraria: $e");
      throw e;
    }
  }

  Stream<QuerySnapshot> getFasceOrarieStreamByTutorId(String tutorId, bool ruolo) {

    if(ruolo)
    {
      Query query = FirebaseFirestore.instance
          .collection('calendario')
          .where('tutorRef', isEqualTo: FirebaseFirestore.instance.doc('utenti/$tutorId'));
      return query.snapshots(); // Restituisce uno stream in tempo reale
    }else{
      Query query = FirebaseFirestore.instance
          .collection('calendario')
          .where('tutorRef', isEqualTo: FirebaseFirestore.instance.doc('utenti/$tutorId'))
          .where('statoPren', isEqualTo: false);
      return query.snapshots(); // Restituisce uno stream in tempo reale
    }
  }
}
