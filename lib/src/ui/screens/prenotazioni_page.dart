import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/viewmodels/prenotazioni_view_model.dart';

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
    // Esegui la chiamata a caricaPrenotazioni una volta che la build iniziale è completata
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PrenotazioniViewModel>(context, listen: false).caricaPrenotazioni(widget.userId, widget.ruolo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Le tue prenotazioni'),
      ),
      body: Consumer<PrenotazioniViewModel>(
        builder: (context, prenotazioniViewModel, child) {
          if (prenotazioniViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (prenotazioniViewModel.prenotazioni.isEmpty) {
            return const Center(
              child: Text(
                'Non ci sono prenotazioni disponibili.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: prenotazioniViewModel.prenotazioni.length,
            itemBuilder: (context, index) {
              final prenotazione = prenotazioniViewModel.prenotazioni[index];

              return ListTile(
                title: FutureBuilder<String>(
                  future: prenotazioniViewModel.getMateriaFromAnnuncio(prenotazione.annuncioRef),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Caricamento...');
                    } else if (snapshot.hasError) {
                      return const Text('Errore nel caricamento della materia');
                    } else {
                      return Text('Materia: ${snapshot.data}');
                    }
                  },
                ),
                subtitle: FutureBuilder<String>(
                  future: prenotazioniViewModel.getNomeDaRef(widget.ruolo ? prenotazione.studenteRef : prenotazione.tutorRef),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Caricamento...');
                    } else if (snapshot.hasError) {
                      return const Text('Errore nel caricamento del nome');
                    } else {
                      return Text('Nome: ${snapshot.data}');
                    }
                  },
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    prenotazioniViewModel.eliminaPrenotazione(prenotazione.fasciaCalendarioRef);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
