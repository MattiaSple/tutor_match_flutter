import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/viewmodels/home_studente_view_model.dart';

class HomeStudente extends StatefulWidget {
  final String userId;
  final bool ruolo;

  const HomeStudente({required this.userId, required this.ruolo, super.key});
  @override
  _HomeStudenteState createState() => _HomeStudenteState();
}

class _HomeStudenteState extends State<HomeStudente> {
  Map<String, int> selectedFeedback = {}; // Mappa per tracciare il feedback selezionato per ogni tutor

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final homeStudenteViewModel = Provider.of<HomeStudenteViewModel>(context, listen: false);
    homeStudenteViewModel.caricaUtente(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Studente'),
      ),
      body: Consumer<HomeStudenteViewModel>(
        builder: (context, homeStudenteViewModel, child) {
          if (homeStudenteViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (homeStudenteViewModel.utente == null) {
            return const Center(child: Text('Errore nel caricamento del profilo'));
          }

          final tutorDaValutare = homeStudenteViewModel.tutorNomi;

          return Column(
            children: [
              if (tutorDaValutare.isNotEmpty) ...[
                const Text(
                  'Tutor da valutare:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: tutorDaValutare.length,
                    itemBuilder: (context, index) {
                      String tutorId = tutorDaValutare.keys.elementAt(index);
                      String nomeTutor = tutorDaValutare[tutorId] ?? '';

                      // Imposta il valore iniziale a 1 se non è già stato selezionato un feedback
                      selectedFeedback[tutorId] = selectedFeedback[tutorId] ?? 1;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(nomeTutor, style: const TextStyle(fontSize: 16))),
                          DropdownButton<int>(
                            value: selectedFeedback[tutorId],
                            items: List.generate(5, (i) => i + 1).map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text('$value'),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectedFeedback[tutorId] = newValue!;
                              });
                            },
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              // Salva il feedback quando premi il bottone
                              await homeStudenteViewModel.salvaFeedback(tutorId, selectedFeedback[tutorId]!);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Feedback salvato!')),
                              );

                              setState(() {
                                // Rimuovi il tutor dalla lista una volta valutato
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
                const Text(
                  'Non ci sono tutor da valutare.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ]
            ],
          );
        },
      ),
    );
  }
}
