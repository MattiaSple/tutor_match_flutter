import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/viewmodels/ricerca_tutor_view_model.dart';
import 'package:tutormatch/src/ui/screens/orari_disponibili_page.dart'; // Aggiungi la pagina corretta per la navigazione

// Classe che rappresenta la pagina di ricerca tutor
class RicercaTutorPage extends StatefulWidget {
  final String userId; // ID dell'utente
  final bool ruolo; // Ruolo dell'utente (true = tutor, false = studente)

  const RicercaTutorPage({required this.userId, required this.ruolo, super.key});

  @override
  _RicercaTutorPageState createState() => _RicercaTutorPageState();
}

class _RicercaTutorPageState extends State<RicercaTutorPage> {
  String? materiaSelezionata; // Variabile per memorizzare la materia selezionata
  final List<String> materieDisponibili = [ // Lista di tutte le materie disponibili
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

  final TextEditingController _cittaController = TextEditingController(); // Controller per il campo di input della città

  @override
  Widget build(BuildContext context) {
    final ricercaViewModel = Provider.of<RicercaTutorViewModel>(context); // ViewModel per la logica della ricerca

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ricerca Tutor'), // Titolo della pagina
        centerTitle: true, // Centra il titolo
        automaticallyImplyLeading: false, // Rimuove il pulsante "indietro"
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Filtra per Materia e Città:', // Testo descrittivo
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Campo di input per la città
            TextField(
              controller: _cittaController, // Associa il controller
              decoration: const InputDecoration(
                labelText: 'Inserisci Città',
                prefixIcon: Icon(Icons.location_city), // Icona accanto al campo
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Dropdown per selezionare una materia
            DropdownButton<String>(
              value: materiaSelezionata, // Materia attualmente selezionata
              hint: const Text('Scegli una materia'),
              isExpanded: true, // Allarga il dropdown per occupare tutta la larghezza
              items: materieDisponibili.map((String materia) { // Crea una lista di elementi
                return DropdownMenuItem<String>(
                  value: materia,
                  child: Text(materia),
                );
              }).toList(),
              onChanged: (String? nuovaMateria) {
                setState(() {
                  materiaSelezionata = nuovaMateria; // Aggiorna la materia selezionata
                });
              },
            ),
            const SizedBox(height: 16),

            // Bottone per cercare gli annunci
            ElevatedButton(
              onPressed: () {
                // Controlla che sia stata selezionata una materia e inserita una città
                if (materiaSelezionata != null && _cittaController.text.isNotEmpty) {
                  ricercaViewModel.cercaAnnunciPerCittaEMateria(
                    _cittaController.text.trim(),
                    materiaSelezionata!,
                  );
                } else {
                  // Mostra un messaggio di errore se mancano dati
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
                  ? const Center(child: Text('Nessun annuncio trovato')) // Messaggio di fallback
                  : ListView.builder(
                itemCount: ricercaViewModel.annunci.length, // Numero di annunci trovati
                itemBuilder: (context, index) {
                  final annuncio = ricercaViewModel.annunci[index]; // Singolo annuncio

                  // FutureBuilder per caricare i dettagli del tutor
                  return FutureBuilder(
                    future: ricercaViewModel.getTutorFromAnnuncio(annuncio.tutorRef), // Ottiene il tutor
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
                        final utente = snapshot.data; // Dettagli del tutor

                        // Calcolo della media del feedback
                        final mediaFeedback = (utente.feedback.isNotEmpty)
                            ? (utente.feedback.map((f) => int.tryParse(f.toString())).reduce((a, b) => a + b) /
                            utente.feedback.length).toStringAsFixed(1)
                            : 'N/A';

                        // Card per ogni tutor
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4D7881),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            title: Text(
                              'Tutor: ${utente.nome} ${utente.cognome}', // Nome del tutor
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Feedback: $mediaFeedback\nResidenza: ${utente.residenza}\nMateria: ${annuncio.materia}', // Dettagli del tutor
                              style: const TextStyle(color: Colors.white70),
                            ),
                            onTap: () {
                              // Navigazione alla pagina degli orari disponibili
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrariDisponibiliPage(
                                    tutorId: utente.userId, // ID del tutor
                                    userId: widget.userId, // ID dello studente
                                    annuncioId: annuncio.id, // ID dell'annuncio
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
