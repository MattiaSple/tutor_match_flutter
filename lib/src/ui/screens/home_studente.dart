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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Carichiamo i dati solo se non sono stati ancora caricati
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
            // Mostra il loader finché i dati non sono stati caricati
            return const Center(child: CircularProgressIndicator());
          }

          if (homeStudenteViewModel.utente == null) {
            // In caso di errore o assenza di dati
            return const Center(child: Text('Errore nel caricamento del profilo'));
          }

          final tutorDaValutare = homeStudenteViewModel.tutorDaValutare;

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
                      return ListTile(
                        title: Text(tutorDaValutare[index]),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // Qui potresti implementare la funzione di valutazione del tutor
                          },
                          child: const Text('Valuta'),
                        ),
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
