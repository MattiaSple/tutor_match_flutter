import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/viewmodels/calendario_view_model.dart';
import 'package:tutormatch/src/viewmodels/prenotazioni_view_model.dart';

class OrariDisponibiliPage extends StatefulWidget {
  final String tutorId;
  final String userId; // ID dello studente che prenota
  final String annuncioId; // ID dell'annuncio

  const OrariDisponibiliPage({
    required this.tutorId,
    required this.userId,
    required this.annuncioId, // Aggiungi annuncioId come parametro richiesto
    super.key,
  });

  @override
  _OrariDisponibiliPageState createState() => _OrariDisponibiliPageState();
}

class _OrariDisponibiliPageState extends State<OrariDisponibiliPage> {
  List<String> fasceSelezionate = []; // Lista delle fasce selezionate dallo studente
  bool isBooking = false; // Inizializzazione della variabile per disabilitare temporaneamente il pulsante

  @override
  void initState() {
    super.initState();
    // Attiva il listener in tempo reale per le fasce orarie
    Provider.of<CalendarioViewModel>(context, listen: false).listenToFasceOrarie(widget.tutorId,false);
  }

  @override
  Widget build(BuildContext context) {
    final calendarioViewModel = Provider.of<CalendarioViewModel>(context);
    final prenotazioniViewModel = Provider.of<PrenotazioniViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prenota le tue lezioni'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Lezioni disponibili:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Verifica se ci sono fasce orarie disponibili
            Expanded(
              child: calendarioViewModel.fasceOrarie.isEmpty
                  ? const Center(child: Text('Nessuna fascia disponibile'))
                  : ListView.builder(
                itemCount: calendarioViewModel.fasceOrarie.length,
                itemBuilder: (context, index) {
                  final fascia = calendarioViewModel.fasceOrarie[index];
                  final dataFascia = '${fascia.data.toLocal().toString().split(' ')[0]}';
                  final orarioFascia = '${fascia.oraInizio} - ${fascia.oraFine}';

                  // Crea un identificatore unico basato su data e ora di inizio
                  final fasciaIdentifier = '${fascia.data.toIso8601String()}_${fascia.oraInizio}';

                  return CheckboxListTile(
                    title: Text('Data: $dataFascia, Orario: $orarioFascia'),
                    value: fasceSelezionate.contains(fasciaIdentifier),
                    onChanged: (bool? isChecked) {
                      setState(() {
                        if (isChecked != null && isChecked) {
                          // Aggiunge l'identificatore alla lista di selezionati
                          fasceSelezionate.add(fasciaIdentifier);
                        } else {
                          // Rimuove l'identificatore dalla lista di selezionati
                          fasceSelezionate.remove(fasciaIdentifier);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fasceSelezionate.isEmpty || isBooking
                  ? null
                  : () {
                // Disabilita temporaneamente il pulsante
                setState(() => isBooking = true);

                prenotazioniViewModel
                    .creaPrenotazioni(widget.userId, widget.tutorId, widget.annuncioId, fasceSelezionate)
                    .then((_) {
                  setState(() {
                    // Dopo la prenotazione, aggiorna fasceSelezionate per rimuovere quelle già prenotate
                    fasceSelezionate = fasceSelezionate.where((fasciaId) {
                      return calendarioViewModel.fasceOrarie.any((fascia) {
                        final idFascia = '${fascia.data.toIso8601String()}_${fascia.oraInizio}';
                        return idFascia == fasciaId && !fascia.statoPren;
                      });
                    }).toList();

                    isBooking = false; // Riabilita il pulsante
                  });
                })
                    .catchError((error) {
                  print("Errore durante la prenotazione: $error");
                  setState(() => isBooking = false); // Riabilita il pulsante in caso di errore
                });
              },
              child: const Text('Prenota'),
            ),
          ],
        ),
      ),
    );
  }
}