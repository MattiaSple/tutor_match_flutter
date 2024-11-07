import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/viewmodels/annuncio_view_model.dart';

class HomeTutor extends StatefulWidget {
  final String userId;
  final bool ruolo;

  const HomeTutor({required this.userId, required this.ruolo, super.key});

  @override
  _HomeTutorState createState() => _HomeTutorState();
}

class _HomeTutorState extends State<HomeTutor> {
  String? selectedMateria;
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

    // Chiama la funzione per recuperare gli annunci dell'utente
    final annuncioViewModel = Provider.of<AnnuncioViewModel>(context, listen: false);
    annuncioViewModel.getAnnunciByUserId(widget.userId);
  }

  // Funzione per creare l'annuncio
  void _creaAnnuncio(AnnuncioViewModel annuncioViewModel) {
    if (selectedMateria != null) {
      // Controlla se la materia selezionata è già presente negli annunci
      bool materiaEsistente = annuncioViewModel.annunci.any((annuncio) => annuncio['materia'] == selectedMateria);

      if (materiaEsistente) {
        // Mostra un messaggio di errore se l'annuncio per la materia esiste già
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Annuncio già esistente per la materia: $selectedMateria')),
        );
      } else {
        // Crea l'annuncio se non esiste ancora
        annuncioViewModel.creaAnnuncio(widget.userId, selectedMateria!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Annuncio creato con successo per materia: $selectedMateria')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona una materia')),
      );
    }
  }

  // Funzione per eliminare un annuncio
  void _eliminaAnnuncio(String annuncioId, AnnuncioViewModel annuncioViewModel) {
    annuncioViewModel.eliminaAnnuncio(annuncioId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Annuncio eliminato con successo')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final annuncioViewModel = Provider.of<AnnuncioViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Tutor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8, // Define max height
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                hint: const Text('Seleziona una materia'),
                value: selectedMateria,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedMateria = newValue;
                  });
                },
                items: materie.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              ElevatedButton(
                onPressed: () => _creaAnnuncio(annuncioViewModel),
                child: const Text('Crea Annuncio'),
              ),
              Flexible(
                fit: FlexFit.loose,
                child: ListView.builder(
                  itemCount: annuncioViewModel.annunci.length,
                  itemBuilder: (context, index) {
                    final annuncio = annuncioViewModel.annunci[index];
                    return ListTile(
                      title: Text(annuncio['materia']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _eliminaAnnuncio(annuncio["id"], annuncioViewModel);
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
