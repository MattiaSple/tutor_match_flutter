import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/viewmodels/profilo_view_model.dart';

class ProfiloPage extends StatefulWidget {
  final String userId;
  final bool ruolo;

  const ProfiloPage({required this.userId, required this.ruolo, super.key});

  @override
  _ProfiloPageState createState() => _ProfiloPageState();
}

class _ProfiloPageState extends State<ProfiloPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Esegui la chiamata a caricaProfilo una volta che la build iniziale è completata
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfiloViewModel>(context, listen: false).caricaProfilo(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifica Profilo'),
        centerTitle: true, // Centra il titolo
        automaticallyImplyLeading: false, // Rimuove la freccia indietro
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<ProfiloViewModel>(context, listen: false).logoutEReindirizza(context);
            },
          ),
        ],
      ),

      body: Consumer<ProfiloViewModel>(
        builder: (context, profiloViewModel, child) {
          if (profiloViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (profiloViewModel.errore != null) {
            return Center(
              child: Text(profiloViewModel.errore!),
            );
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.ruolo && profiloViewModel.feedback.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'La tua valutazione: ${profiloViewModel.mediaFeedback.toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, color: Colors.yellow, size: 30),
                        ],
                      ),
                    TextFormField(
                      initialValue: profiloViewModel.nome,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      onSaved: (value) => profiloViewModel.nome = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci il nome';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      initialValue: profiloViewModel.cognome,
                      decoration: const InputDecoration(labelText: 'Cognome'),
                      onSaved: (value) => profiloViewModel.cognome = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Inserisci il cognome';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          if (profiloViewModel.nome != null && profiloViewModel.cognome != null) {
                            profiloViewModel.aggiornaProfilo(profiloViewModel.nome!, profiloViewModel.cognome!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profilo aggiornato con successo')),
                            );
                          }
                        }
                      },
                      child: const Text('Salva modifiche'),
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
