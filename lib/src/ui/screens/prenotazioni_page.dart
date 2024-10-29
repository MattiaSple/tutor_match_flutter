import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/viewmodels/prenotazioni_view_model.dart';
import 'package:tutormatch/src/viewmodels/calendario_view_model.dart';

class PrenotazioniPage extends StatefulWidget {
  final String userId;
  final bool ruolo;

  const PrenotazioniPage({required this.userId, required this.ruolo, super.key});

  @override
  _PrenotazioniPageState createState() => _PrenotazioniPageState();
}

class _PrenotazioniPageState extends State<PrenotazioniPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Attiva il listener per le prenotazioni in tempo reale
      Provider.of<PrenotazioniViewModel>(context, listen: false)
          .listenToPrenotazioni(widget.userId, widget.ruolo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Le tue prenotazioni'),
      ),
      body: Consumer2<PrenotazioniViewModel, CalendarioViewModel>(
        builder: (context, prenotazioniViewModel, calendarioViewModel, child) {
          if (prenotazioniViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

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
            itemCount: prenotazioniViewModel.prenotazioni.length,
            itemBuilder: (context, index) {
              final prenotazione = prenotazioniViewModel.prenotazioni[index];

              return FutureBuilder(
                future: Future.wait([
                  prenotazioniViewModel.getMateriaFromAnnuncio(prenotazione.annuncioRef.id),
                  prenotazioniViewModel.getNomeDaRef(
                      widget.ruolo ? prenotazione.studenteRef : prenotazione.tutorRef),
                  calendarioViewModel.getOrarioFascia(prenotazione.fasciaCalendarioRef),
                ]),
                builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    print("Errore nel caricamento della prenotazione: ${snapshot.error}");
                    return const ListTile(
                      title: Text('Errore nel caricamento della prenotazione'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const ListTile(
                      title: Text('Dati prenotazione non disponibili'),
                    );
                  } else {
                    final materia = snapshot.data![0] as String;
                    final nome = snapshot.data![1] as String;
                    final orari = snapshot.data![2] as Map<String, String>;
                    final data = orari['data'] ?? 'N/A';
                    final oraInizio = orari['oraInizio'] ?? 'N/A';
                    final oraFine = orari['oraFine'] ?? 'N/A';

                    return Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4D7881),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        title: Text(
                          'Materia: $materia',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${widget.ruolo ? "Studente" : "Tutor"}: $nome\nData: $data\nOrario: $oraInizio - $oraFine',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            // Elimina la prenotazione
                            await prenotazioniViewModel
                                .eliminaPrenotazione(prenotazione.fasciaCalendarioRef, prenotazione.tutorRef);
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
