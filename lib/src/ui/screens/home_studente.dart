import 'package:flutter/material.dart'; // Importa il framework per l'interfaccia utente.
import 'package:provider/provider.dart'; // Per la gestione dello stato tramite Provider.
import 'package:tutormatch/src/viewmodels/home_studente_view_model.dart'; // ViewModel per la gestione della home studente.

class HomeStudente extends StatefulWidget {
  final String userId; // ID dell'utente corrente.
  final bool ruolo; // Ruolo dell'utente (true = tutor, false = studente).

  const HomeStudente({required this.userId, required this.ruolo, super.key});

  @override
  _HomeStudenteState createState() => _HomeStudenteState();
}

class _HomeStudenteState extends State<HomeStudente> {
  // Mappa per tracciare il feedback selezionato per ogni tutor.
  Map<String, int> selectedFeedback = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Carica i dati dell'utente al cambio di dipendenze.
    final homeStudenteViewModel =
    Provider.of<HomeStudenteViewModel>(context, listen: false);
    homeStudenteViewModel.caricaUtente(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Studente'), // Titolo della pagina.
        centerTitle: true, // Centra il titolo nell'AppBar.
        automaticallyImplyLeading: false, // Rimuove il pulsante di navigazione indietro.
      ),
      body: Consumer<HomeStudenteViewModel>(
        builder: (context, homeStudenteViewModel, child) {
          if (homeStudenteViewModel.isLoading) {
            // Mostra un indicatore di caricamento durante il fetch dei dati.
            return const Center(child: CircularProgressIndicator());
          }

          if (homeStudenteViewModel.utente == null) {
            // Mostra un messaggio di errore se il caricamento fallisce.
            return const Center(child: Text('Errore nel caricamento del profilo'));
          }

          // Recupera la lista dei tutor da valutare.
          final tutorDaValutare = homeStudenteViewModel.tutorNomi;

          return Column(
            children: [
              if (tutorDaValutare.isNotEmpty) ...[
                // Se ci sono tutor da valutare, mostra un titolo e la lista.
                const Text(
                  'Tutor da valutare:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tutorDaValutare.length, // Numero di tutor da valutare.
                    itemBuilder: (context, index) {
                      // Ottiene l'ID e il nome del tutor corrente.
                      String tutorId = tutorDaValutare.keys.elementAt(index);
                      String nomeTutor = tutorDaValutare[tutorId] ?? '';

                      // Inizializza il feedback a 1 se non già presente.
                      selectedFeedback[tutorId] = selectedFeedback[tutorId] ?? 1;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spazia gli elementi orizzontalmente.
                        children: [
                          // Mostra il nome del tutor.
                          Expanded(child: Text(nomeTutor, style: const TextStyle(fontSize: 16))),
                          // Dropdown per selezionare il feedback.
                          DropdownButton<int>(
                            value: selectedFeedback[tutorId], // Valore selezionato.
                            items: List.generate(5, (i) => i + 1).map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text('$value'), // Mostra il valore come opzione.
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                // Aggiorna il feedback selezionato.
                                selectedFeedback[tutorId] = newValue!;
                              });
                            },
                          ),
                          // Pulsante per inviare il feedback.
                          ElevatedButton(
                            onPressed: () async {
                              // Salva il feedback quando il pulsante è premuto.
                              await homeStudenteViewModel.salvaFeedback(tutorId, selectedFeedback[tutorId]!);

                              // Mostra una notifica di conferma.
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Feedback salvato!')),
                              );

                              setState(() {
                                // Rimuove il tutor dalla lista dopo la valutazione.
                                tutorDaValutare.remove(tutorId);
                              });
                            },
                            child: const Text('Valuta'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ] else ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'Non ci sono tutor da valutare.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                ),
              ]
            ],
          );
        },
      ),
    );
  }
}
