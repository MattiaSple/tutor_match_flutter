import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/viewmodels/profilo_view_model.dart';

// Classe ProfiloPage: consente agli utenti di visualizzare e modificare il proprio profilo
class ProfiloPage extends StatefulWidget {
  final String userId; // ID univoco dell'utente
  final bool ruolo; // true = Tutor, false = Studente

  const ProfiloPage({required this.userId, required this.ruolo, super.key});

  @override
  _ProfiloPageState createState() => _ProfiloPageState();
}

class _ProfiloPageState extends State<ProfiloPage> {
  final _formKey = GlobalKey<FormState>(); // Chiave globale per il form

  @override
  void initState() {
    super.initState();
    // Carica il profilo dell'utente al primo avvio della schermata
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfiloViewModel>(context, listen: false).caricaProfilo(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifica Profilo'), // Titolo della pagina
        centerTitle: true, // Centra il titolo
        automaticallyImplyLeading: false, // Rimuove il pulsante "indietro"
        actions: [
          // Icona di logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Effettua il logout e reindirizza alla schermata di login
              Provider.of<ProfiloViewModel>(context, listen: false).logoutEReindirizza(context);
            },
          ),
        ],
      ),

      // Consumer per aggiornare dinamicamente il contenuto in base al ProfiloViewModel
      body: Consumer<ProfiloViewModel>(
        builder: (context, profiloViewModel, child) {
          if (profiloViewModel.isLoading) {
            // Mostra un indicatore di caricamento se i dati sono in fase di caricamento
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (profiloViewModel.errore != null) {
            // Mostra un messaggio di errore se presente
            return Center(
              child: Text(profiloViewModel.errore!),
            );
          }

          // Visualizza il modulo per modificare il profilo
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey, // Assegna la chiave al form
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Se l'utente è un tutor e ha ricevuto feedback, mostra la valutazione media
                    if (widget.ruolo && profiloViewModel.feedback.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'La tua valutazione: ${profiloViewModel.mediaFeedback.toStringAsFixed(1)}', // Mostra la media del feedback
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, color: Colors.yellow, size: 30), // Icona stella
                        ],
                      ),

                    // Campo di input per il nome
                    TextFormField(
                      initialValue: profiloViewModel.nome, // Mostra il nome corrente
                      decoration: const InputDecoration(labelText: 'Nome'),
                      onSaved: (value) => profiloViewModel.nome = value, // Salva il nuovo valore
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci il nome'; // Mostra un messaggio di errore se vuoto
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Campo di input per il cognome
                    TextFormField(
                      initialValue: profiloViewModel.cognome, // Mostra il cognome corrente
                      decoration: const InputDecoration(labelText: 'Cognome'),
                      onSaved: (value) => profiloViewModel.cognome = value, // Salva il nuovo valore
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci il cognome'; // Mostra un messaggio di errore se vuoto
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),

                    // Pulsante per salvare le modifiche
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save(); // Salva i valori del form
                          if (profiloViewModel.nome != null && profiloViewModel.cognome != null) {
                            // Aggiorna il profilo con i nuovi valori
                            profiloViewModel.aggiornaProfilo(profiloViewModel.nome!, profiloViewModel.cognome!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profilo aggiornato con successo')), // Notifica il successo
                            );
                          }
                        }
                      },
                      child: const Text('Salva modifiche'), // Testo del pulsante
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
