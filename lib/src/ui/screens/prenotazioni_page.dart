import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/viewmodels/prenotazioni_view_model.dart';
import 'package:tutormatch/src/viewmodels/calendario_view_model.dart';

// Pagina per la visualizzazione e gestione delle prenotazioni
class PrenotazioniPage extends StatefulWidget {
  final String userId; // ID dell'utente corrente
  final bool ruolo; // true = Tutor, false = Studente

  const PrenotazioniPage({required this.userId, required this.ruolo, super.key});

  @override
  _PrenotazioniPageState createState() => _PrenotazioniPageState();
}

class _PrenotazioniPageState extends State<PrenotazioniPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Attiva il listener per ricevere aggiornamenti in tempo reale sulle prenotazioni
      Provider.of<PrenotazioniViewModel>(context, listen: false)
          .listenToPrenotazioni(widget.userId, widget.ruolo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Le tue prenotazioni'), // Titolo della pagina
        centerTitle: true, // Centra il titolo
        automaticallyImplyLeading: false, // Rimuove il pulsante "indietro"
      ),
      body: Consumer2<PrenotazioniViewModel, CalendarioViewModel>(
        builder: (context, prenotazioniViewModel, calendarioViewModel, child) {
          // Mostra un indicatore di caricamento se i dati sono ancora in fase di caricamento
          if (prenotazioniViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Se non ci sono prenotazioni, mostra un messaggio all'utente
          return prenotazioniViewModel.prenotazioni.isEmpty
              ? ListView(
            children: const [
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    'Non ci sono prenotazioni disponibili.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              ),
            ],
          )
              : ListView.builder(
            itemCount: prenotazioniViewModel.prenotazioni.length, // Numero di prenotazioni disponibili
            itemBuilder: (context, index) {
              final prenotazione = prenotazioniViewModel.prenotazioni[index];

              // Usa FutureBuilder per recuperare i dettagli relativi alla prenotazione
              return FutureBuilder(
                future: Future.wait([
                  // Recupera materia dall'annuncio
                  prenotazioniViewModel.getMateriaFromAnnuncio(prenotazione.annuncioRef.id),
                  // Recupera nome dell'altro partecipante (Studente o Tutor)
                  prenotazioniViewModel.getNomeDaRef(
                      widget.ruolo ? prenotazione.studenteRef : prenotazione.tutorRef),
                  // Recupera data e orari dalla fascia prenotata
                  calendarioViewModel.getOrarioFascia(prenotazione.fasciaCalendarioRef),
                ]),
                builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                  // Mostra un indicatore di caricamento finché i dati non sono disponibili
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    // Gestione degli errori
                    print("Errore nel caricamento della prenotazione: ${snapshot.error}");
                    return const ListTile(
                      title: Text('Errore nel caricamento della prenotazione'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // Mostra un messaggio se i dati della prenotazione non sono disponibili
                    return const ListTile(
                      title: Text('Dati prenotazione non disponibili'),
                    );
                  } else {
                    // Dati recuperati con successo
                    final materia = snapshot.data![0] as String; // Materia dell'annuncio
                    final nome = snapshot.data![1] as String; // Nome dell'altro partecipante
                    final orari = snapshot.data![2] as Map<String, String>; // Orari della fascia
                    final data = orari['data'] ?? 'N/A';
                    final oraInizio = orari['oraInizio'] ?? 'N/A';
                    final oraFine = orari['oraFine'] ?? 'N/A';

                    return Container(
                      margin: const EdgeInsets.all(8), // Margine del contenitore
                      padding: const EdgeInsets.all(20), // Padding interno
                      decoration: BoxDecoration(
                        color: const Color(0xFF4D7881), // Colore di sfondo
                        borderRadius: BorderRadius.circular(20), // Angoli arrotondati
                      ),
                      child: ListTile(
                        title: Text(
                          'Materia: $materia', // Mostra la materia
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${widget.ruolo ? "Studente" : "Tutor"}: $nome\nData: $data\nOrario: $oraInizio - $oraFine', // Mostra i dettagli
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red), // Icona per eliminare
                          onPressed: () async {
                            // Elimina la prenotazione selezionata
                            await prenotazioniViewModel.eliminaPrenotazione(
                              prenotazione.fasciaCalendarioRef,
                              prenotazione.tutorRef,
                            );
                          },
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
