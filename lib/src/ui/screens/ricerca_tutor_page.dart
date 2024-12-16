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
  final List<String> materieDisponibili = [
    'Antropologia', 'Architettura', 'Arte',
    'Astronomia', 'Biologia', 'Biotecnologie',
    'Chimica', 'Chimica farmaceutica', 'Cinema e audiovisivo',
    'Contabilità', 'Design', 'Diritto',
    'Diritto commerciale', 'Diritto internazionale', 'Economia',
    'Economia aziendale', 'Elettronica', 'Elettrotecnica',
    'Filosofia', 'Fisica', 'Fisica nucleare',
    'Fisioterapia', 'Fotografia', 'Francese',
    'Geografia', 'Geologia', 'Giurisprudenza',
    'Informatica', 'Ingegneria civile', 'Ingegneria elettronica',
    'Ingegneria meccanica', 'Inglese', 'Italiano',
    'Latino', 'Letteratura italiana', 'Logistica',
    'Marketing', 'Matematica', 'Medicina',
    'Meccanica', 'Musica', 'Odontoiatria',
    'Pedagogia', 'Psicologia', 'Psicologia clinica',
    'Relazioni internazionali', 'Restauro', 'Robotica',
    'Russo', 'Scenografia', 'Scienze ambientali',
    'Scienze della comunicazione', 'Scienze della terra', 'Scienze dell\'educazione',
    'Scienze infermieristiche', 'Scienze motorie', 'Sociologia',
    'Spagnolo', 'Statistica', 'Storia',
    'Storia contemporanea', 'Storia dell\'arte', 'Storia moderna',
    'Teatro', 'Tedesco', 'Veterinaria',
  ];

  final TextEditingController _cittaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ricercaViewModel = Provider.of<RicercaTutorViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ricerca Tutor'),
        centerTitle: true, // Centra il titolo
        automaticallyImplyLeading: false, // Rimuove la freccia indietro
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Filtra per Materia e Città:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Campo di ricerca per città
            TextField(
              controller: _cittaController,
              decoration: const InputDecoration(
                labelText: 'Inserisci Città',
                prefixIcon: Icon(Icons.location_city),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Dropdown per la materia
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
              onPressed: () {
                if (materiaSelezionata != null &&
                    _cittaController.text.isNotEmpty) {
                  ricercaViewModel.cercaAnnunciPerCittaEMateria(
                    _cittaController.text.trim(),
                    materiaSelezionata!,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Inserisci sia la città che la materia."),
                      backgroundColor: Colors.black,
                    ),
                  );
                }
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
                    future: ricercaViewModel.getTutorFromAnnuncio(
                        annuncio.tutorRef),
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
                            ? (utente.feedback
                            .map((f) => int.tryParse(f.toString()))
                            .reduce((a, b) => a + b) /
                            utente.feedback.length)
                            .toStringAsFixed(1)
                            : 'N/A';

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4D7881),
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
                              'Feedback: $mediaFeedback\nResidenza: ${utente
                                  .residenza}\nMateria: ${annuncio.materia}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      OrariDisponibiliPage(
                                        tutorId: utente.userId,
                                        userId: widget.userId,
                                        annuncioId: annuncio.id,
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