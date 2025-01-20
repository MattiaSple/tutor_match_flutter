import 'package:flutter/material.dart';
import 'package:tutormatch/src/ui/screens/home_studente.dart';
import 'package:tutormatch/src/ui/screens/prenotazioni_page.dart';
import 'package:tutormatch/src/ui/screens/chat_page.dart';
import 'package:tutormatch/src/ui/screens/profilo_page.dart';
import 'package:tutormatch/src/ui/screens/ricerca_tutor_page.dart';

// Classe principale per la schermata principale dello studente
class MainPageStudente extends StatefulWidget {
  const MainPageStudente({super.key}); // Costruttore

  @override
  _MainPageStudenteState createState() => _MainPageStudenteState(); // Stato associato
}

class _MainPageStudenteState extends State<MainPageStudente> {
  int _selectedIndex = 2; // Indice della pagina corrente selezionata

  @override
  Widget build(BuildContext context) {
    // Recupera gli argomenti passati alla schermata (userId e ruolo)
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final String userId = arguments['userId']; // ID dell'utente
    final bool ruolo = arguments['ruolo']; // Ruolo dell'utente (studente/tutor)

    // Definizione delle pagine disponibili
    final List<Widget> _studentPages = [
      ProfiloPage(userId: userId, ruolo: ruolo),         // Pagina Profilo
      PrenotazioniPage(userId: userId, ruolo: ruolo),    // Pagina Prenotazioni
      HomeStudente(userId: userId, ruolo: ruolo),        // Pagina Home Studente
      ChatPage(userId: userId, ruolo: ruolo),            // Pagina Chat
      RicercaTutorPage(userId: userId, ruolo: ruolo),    // Pagina Ricerca Tutor
    ];

    // Funzione chiamata quando l'utente seleziona un elemento nella barra inferiore
    void _onItemTapped(int index) {
      if (_selectedIndex != index) {
        // Cambia pagina solo se l'indice è diverso dall'attuale
        setState(() {
          _selectedIndex = index; // Aggiorna l'indice della pagina corrente
        });
      }
      // Se l'indice è lo stesso, non fare nulla
    }

    return Scaffold(
      body: IndexedStack(
        // Visualizza una sola pagina alla volta usando l'indice selezionato
        index: _selectedIndex,  // Indice della pagina corrente
        children: _studentPages,  // Lista delle pagine disponibili
      ),
      bottomNavigationBar: BottomNavigationBar(
        // Barra di navigazione inferiore
        type: BottomNavigationBarType.fixed,  // Tipo fisso per evitare il comportamento predefinito
        currentIndex: _selectedIndex,  // Indice corrente
        onTap: _onItemTapped,  // Chiama la funzione _onItemTapped quando si tocca un elemento
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profilo', // Elemento per accedere alla pagina Profilo
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Prenotazioni', // Elemento per accedere alla pagina Prenotazioni
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home', // Elemento per accedere alla Home
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat', // Elemento per accedere alla Chat
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Ricerca Tutor', // Elemento per accedere alla Ricerca Tutor
          ),
        ],
        backgroundColor: const Color(0xFF4D7881), // Colore di sfondo della barra inferiore
        selectedItemColor: Colors.white, // Colore dell'elemento selezionato
        unselectedItemColor: Colors.white54, // Colore degli elementi non selezionati
      ),
    );
  }
}
