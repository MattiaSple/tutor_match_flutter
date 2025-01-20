import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/viewmodels/calendario_view_model.dart';
import 'package:tutormatch/src/viewmodels/prenotazioni_view_model.dart';
import '../../viewmodels/chat_view_model.dart';

// Pagina per visualizzare e prenotare lezioni disponibili
class OrariDisponibiliPage extends StatefulWidget {
  final String tutorId; // ID del tutor
  final String userId; // ID dello studente che prenota
  final String annuncioId; // ID dell'annuncio

  const OrariDisponibiliPage({
    required this.tutorId,
    required this.userId,
    required this.annuncioId, // Parametro richiesto per identificare l'annuncio
    super.key,
  });

  @override
  _OrariDisponibiliPageState createState() => _OrariDisponibiliPageState();
}

class _OrariDisponibiliPageState extends State<OrariDisponibiliPage> {
  List<String> fasceSelezionate = []; // Lista delle fasce selezionate per la prenotazione
  bool isBooking = false; // Flag per gestire lo stato del pulsante di prenotazione

  @override
  void initState() {
    super.initState();
    // Avvia il listener per ottenere fasce orarie disponibili
    Provider.of<CalendarioViewModel>(context, listen: false).listenToFasceOrarie(widget.tutorId, false);
  }

  @override
  Widget build(BuildContext context) {
    final calendarioViewModel = Provider.of<CalendarioViewModel>(context); // ViewModel per le fasce orarie
    final prenotazioniViewModel = Provider.of<PrenotazioniViewModel>(context); // ViewModel per le prenotazioni
    final chatViewModel = Provider.of<ChatViewModel>(context); // ViewModel per le chat

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prenota le tue lezioni'), // Titolo della pagina
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Lezioni disponibili:', // Testo introduttivo
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Mostra la lista delle fasce orarie disponibili
            Expanded(
              child: calendarioViewModel.fasceOrarie.isEmpty
                  ? const Center(child: Text('Nessuna fascia disponibile')) // Messaggio in caso di nessuna fascia
                  : ListView.builder(
                itemCount: calendarioViewModel.fasceOrarie.length,
                itemBuilder: (context, index) {
                  final fascia = calendarioViewModel.fasceOrarie[index];
                  final dataFascia = '${fascia.data.toLocal().toString().split(' ')[0]}'; // Data della fascia
                  final orarioFascia = '${fascia.oraInizio} - ${fascia.oraFine}'; // Orario della fascia

                  // Identificatore unico basato su data e ora di inizio
                  final fasciaIdentifier = '${fascia.data.toIso8601String()}_${fascia.oraInizio}';

                  return CheckboxListTile(
                    title: Text('Data: $dataFascia, Orario: $orarioFascia'),
                    value: fasceSelezionate.contains(fasciaIdentifier), // Stato del checkbox
                    onChanged: (bool? isChecked) {
                      setState(() {
                        if (isChecked != null && isChecked) {
                          fasceSelezionate.add(fasciaIdentifier); // Aggiungi alla lista delle fasce selezionate
                        } else {
                          fasceSelezionate.remove(fasciaIdentifier); // Rimuovi dalla lista
                        }
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Bottone per confermare la prenotazione
            ElevatedButton(
              onPressed: fasceSelezionate.isEmpty || isBooking // Disabilita il pulsante se necessario
                  ? null
                  : () {
                setState(() => isBooking = true); // Disabilita il pulsante temporaneamente

                prenotazioniViewModel
                    .creaPrenotazioni(widget.userId, widget.tutorId, widget.annuncioId, fasceSelezionate)
                    .then((_) {
                  setState(() {
                    // Dopo la prenotazione, aggiorna la lista delle fasce selezionate e crea la chat
                    chatViewModel.creaChat(widget.userId, widget.tutorId, widget.annuncioId);
                    fasceSelezionate = fasceSelezionate.where((fasciaId) {
                      return calendarioViewModel.fasceOrarie.any((fascia) {
                        final idFascia = '${fascia.data.toIso8601String()}_${fascia.oraInizio}';
                        return idFascia == fasciaId && !fascia.statoPren; // Mantieni solo le fasce non prenotate
                      });
                    }).toList();

                    isBooking = false; // Riabilita il pulsante
                  });
                }).catchError((error) {
                  print("Errore durante la prenotazione: $error");
                  setState(() => isBooking = false); // Riabilita il pulsante in caso di errore
                });
              },
              child: const Text('Prenota'), // Testo del bottone
            ),
          ],
        ),
      ),
    );
  }
}
