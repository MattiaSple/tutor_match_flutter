import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/viewmodels/annuncio_view_model.dart';

class HomeTutor extends StatefulWidget {
  const HomeTutor({super.key});

  @override
  _HomeTutorState createState() => _HomeTutorState();
}

class _HomeTutorState extends State<HomeTutor> {
  int _selectedIndex = 0;
  String? selectedMateria;
  List<String> materie = ['Matematica', 'Fisica', 'Informatica'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Recupera l'ID utente passato dalla LoginPage
    final userId = ModalRoute.of(context)?.settings.arguments as String?;

    if (userId != null) {
      // Chiama la funzione per recuperare gli annunci dell'utente
      final annuncioViewModel = Provider.of<AnnuncioViewModel>(context, listen: false);
      annuncioViewModel.getAnnunciByUserId(userId);
    }
  }

  // Funzione per creare l'annuncio
  void _creaAnnuncio(String userId, AnnuncioViewModel annuncioViewModel) {
    if (selectedMateria != null) {
      annuncioViewModel.creaAnnuncio(userId, selectedMateria!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Annuncio creato con successo per materia: $selectedMateria')),
      );
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
    final userId = ModalRoute.of(context)?.settings.arguments as String;

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
                onPressed: () => _creaAnnuncio(userId, annuncioViewModel),
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
                          _eliminaAnnuncio(annuncio['id'], annuncioViewModel);
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
