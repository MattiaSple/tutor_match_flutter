import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/viewmodels/ricerca_tutor_view_model.dart';
import 'package:tutormatch/src/ui/screens/orari_disponibili_page.dart'; // Aggiungi la pagina corretta per la navigazione

class RicercaTutorPage extends StatefulWidget {
  final String userId;
  final bool ruolo;

  const RicercaTutorPage({required this.userId, required this.ruolo, super.key});

  @override
  _RicercaTutorPageState createState() => _RicercaTutorPageState();
}

class _RicercaTutorPageState extends State<RicercaTutorPage> {
  String? materiaSelezionata; // Memorizza la materia selezionata
  final List<String> materieDisponibili = ['Matematica', 'Fisica', 'Chimica', 'Informatica']; // Materie esempio

  @override
  Widget build(BuildContext context) {
    final ricercaViewModel = Provider.of<RicercaTutorViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ricerca Tutor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Seleziona la materia di interesse:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Dropdown per selezionare la materia
            DropdownButton<String>(
              value: materiaSelezionata,
              hint: const Text('Scegli una materia'),
              isExpanded: true,
              items: materieDisponibili.map((String materia) {
                return DropdownMenuItem<String>(
                  value: materia,
                  child: Text(materia),
                );
              }).toList(),
              onChanged: (String? nuovaMateria) {
                setState(() {
                  materiaSelezionata = nuovaMateria;
                });
              },
            ),

            const SizedBox(height: 16),

            // Bottone per cercare gli annunci
            ElevatedButton(
              onPressed: materiaSelezionata == null
                  ? null
                  : () {
                ricercaViewModel.cercaAnnunciPerMateria(materiaSelezionata!);
              },
              child: const Text('Cerca Annunci'),
            ),

            const SizedBox(height: 16),

            // Lista degli annunci trovati
            Expanded(
              child: ricercaViewModel.annunci.isEmpty
                  ? const Center(child: Text('Nessun annuncio trovato'))
                  : ListView.builder(
                itemCount: ricercaViewModel.annunci.length,
                itemBuilder: (context, index) {
                  final annuncio = ricercaViewModel.annunci[index];

                  return FutureBuilder(
                    future: ricercaViewModel.getTutorFromAnnuncio(annuncio.tutorRef), // Usa DocumentReference qui
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const ListTile(
                          title: Text('Caricamento...'),
                        );
                      } else if (snapshot.hasError) {
                        return const ListTile(
                          title: Text('Errore nel caricamento del tutor'),
                        );
                      } else if (snapshot.hasData) {
                        final utente = snapshot.data;

                        final mediaFeedback = (utente.feedback.isNotEmpty)
                            ? (utente.feedback.map((f) => int.tryParse(f.toString())).reduce((a, b) => a + b) / utente.feedback.length).toStringAsFixed(1)
                            : 'N/A';


                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4D7881), // Colore principale dell'app
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            title: Text(
                              'Tutor: ${utente.nome} ${utente.cognome}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Feedback: $mediaFeedback\nResidenza: ${utente.residenza}\nMateria: ${annuncio.materia}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            // Dentro il metodo onTap di ListTile
                            onTap: () {
                              // Naviga alla pagina di scelta degli orari passando anche l'ID dell'annuncio
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrariDisponibiliPage(
                                    tutorId: utente.userId,
                                    userId: widget.userId,
                                    annuncioId: annuncio.id, // Passa l'ID dell'annuncio
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return const ListTile(
                          title: Text('Nessun dato trovato'),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
