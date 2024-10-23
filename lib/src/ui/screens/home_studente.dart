import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/viewmodels/home_studente_view_model.dart';

class HomeStudente extends StatefulWidget {
  const HomeStudente({super.key});

  @override
  _HomeStudenteState createState() => _HomeStudenteState();
}

class _HomeStudenteState extends State<HomeStudente> {
  int _selectedIndex = 0;
  bool _hasLoaded = false; // Variabile per controllare se il caricamento è stato avviato

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Recupera i parametri passati dalla LoginPage
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null && !_hasLoaded) { // Controlla che non stiamo ricaricando più volte
      final String userId = args['userId'] as String;

      // Carica i dati dell'utente tramite il ViewModel
      final homeStudenteViewModel = Provider.of<HomeStudenteViewModel>(context, listen: false);
      homeStudenteViewModel.caricaUtente(userId);
      _hasLoaded = true; // Imposta che abbiamo avviato il caricamento
    }
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profilo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Impostazioni',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF4D7881),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
