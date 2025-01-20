import 'package:flutter/material.dart'; // Per costruire l'interfaccia utente.
import 'package:provider/provider.dart'; // Per la gestione dello stato tramite Provider.
import 'package:tutormatch/src/viewmodels/annuncio_view_model.dart'; // ViewModel per gestire gli annunci.

class HomeTutor extends StatefulWidget {
  final String userId; // ID dell'utente corrente.
  final bool ruolo; // Ruolo dell'utente (true = tutor, false = studente).

  const HomeTutor({required this.userId, required this.ruolo, super.key});

  @override
  _HomeTutorState createState() => _HomeTutorState();
}

class _HomeTutorState extends State<HomeTutor> {
  String? selectedMateria; // Materia selezionata dal tutor.

  // Lista delle materie disponibili.
  List<String> materie = [
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Recupera gli annunci per l'utente corrente.
    final annuncioViewModel = Provider.of<AnnuncioViewModel>(context, listen: false);
    annuncioViewModel.getAnnunciByUserId(widget.userId);
  }

  // Funzione per creare un nuovo annuncio.
  void _creaAnnuncio(AnnuncioViewModel annuncioViewModel) {
    if (selectedMateria != null) {
      // Controlla se esiste già un annuncio per la materia selezionata.
      bool materiaEsistente = annuncioViewModel.annunci.any((annuncio) => annuncio['materia'] == selectedMateria);

      if (materiaEsistente) {
        // Mostra un messaggio di errore se l'annuncio esiste già.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Annuncio già esistente per la materia: $selectedMateria')),
        );
      } else {
        // Crea un nuovo annuncio se non esiste.
        annuncioViewModel.creaAnnuncio(widget.userId, selectedMateria!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Annuncio creato con successo per materia: $selectedMateria')),
        );
      }
    } else {
      // Mostra un messaggio se non è stata selezionata alcuna materia.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona una materia')),
      );
    }
  }

  // Funzione per eliminare un annuncio esistente.
  void _eliminaAnnuncio(String annuncioId, AnnuncioViewModel annuncioViewModel) {
    annuncioViewModel.eliminaAnnuncio(annuncioId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Annuncio eliminato con successo')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final annuncioViewModel = Provider.of<AnnuncioViewModel>(context); // Recupera il ViewModel degli annunci.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Tutor'), // Titolo della pagina.
        centerTitle: true, // Centra il titolo nell'AppBar.
        automaticallyImplyLeading: false, // Rimuove il pulsante di navigazione indietro.
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Aggiunge margini interni.
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8, // Imposta l'altezza massima.
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Colonna con altezza minima necessaria.
            children: [
              // Dropdown per selezionare una materia.
              DropdownButton<String>(
                hint: const Text('Seleziona una materia'), // Testo predefinito.
                value: selectedMateria, // Valore corrente del dropdown.
                onChanged: (String? newValue) {
                  setState(() {
                    selectedMateria = newValue; // Aggiorna la materia selezionata.
                  });
                },
                items: materie.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value), // Mostra il nome della materia.
                  );
                }).toList(),
              ),
              // Bottone per creare un annuncio.
              ElevatedButton(
                onPressed: () => _creaAnnuncio(annuncioViewModel),
                child: const Text('Crea Annuncio'),
              ),
              // Lista degli annunci creati.
              Flexible(
                fit: FlexFit.loose, // Adatta l'altezza della lista.
                child: ListView.builder(
                  itemCount: annuncioViewModel.annunci.length, // Numero di annunci disponibili.
                  itemBuilder: (context, index) {
                    final annuncio = annuncioViewModel.annunci[index]; // Annuncio corrente.
                    return ListTile(
                      title: Text(annuncio['materia']), // Mostra la materia dell'annuncio.
                      trailing: IconButton(
                        icon: const Icon(Icons.delete), // Icona per eliminare l'annuncio.
                        onPressed: () {
                          _eliminaAnnuncio(annuncio["id"], annuncioViewModel); // Elimina l'annuncio.
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
