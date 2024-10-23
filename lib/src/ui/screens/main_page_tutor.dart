import 'package:flutter/material.dart';
import 'package:tutormatch/src/ui/screens/home_tutor.dart';
import 'package:tutormatch/src/ui/screens/prenotazioni_page.dart';
import 'package:tutormatch/src/ui/screens/chat_page.dart';
import 'package:tutormatch/src/ui/screens/profilo_page.dart';
import 'package:tutormatch/src/ui/screens/ricerca_tutor_page.dart';

class MainPageTutor extends StatefulWidget {
  const MainPageTutor({super.key});

  @override
  _MainPageTutorState createState() => _MainPageTutorState();
}

class _MainPageTutorState extends State<MainPageTutor> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Recupera gli argomenti passati (userId e ruolo)
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final String userId = arguments['userId'];
    final bool ruolo = arguments['ruolo'];

    // Le pagine da mostrare nell'IndexedStack, passa userId e ruolo a ciascuna schermata
    final List<Widget> _tutorPages = [
      ProfiloPage(userId: userId, ruolo: ruolo),      // Pagina Profilo
      RicercaTutorPage(userId: userId, ruolo: ruolo), // Pagina Ricerca Tutor
      HomeTutor(userId: userId, ruolo: ruolo),        // Pagina Home Tutor
      ChatPage(userId: userId, ruolo: ruolo),         // Pagina Chat
      PrenotazioniPage(userId: userId, ruolo: ruolo), // Pagina Prenotazioni
    ];

    // Funzione per cambiare pagina
    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,  // Usa _selectedIndex per decidere quale pagina mostrare
        children: _tutorPages,  // Le pagine disponibili sono definite in _tutorPages
      ),

      // BottomNavigationBar che consente all'utente di cambiare pagina
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Imposta il tipo per evitare il comportamento di Material 3
        currentIndex: _selectedIndex,  // Imposta l'indice corrente sulla barra inferiore
        onTap: _onItemTapped,  // Chiama _onItemTapped quando l'utente tocca un'icona
        items: const <BottomNavigationBarItem>[  // Definisce le icone e i label per la barra
          BottomNavigationBarItem(
            icon: Icon(Icons.person),  // Icona del profilo
            label: 'Profilo',          // Testo 'Profilo'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),  // Icona della ricerca
            label: 'Calendario',    // Testo 'Ricerca Tutor'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),  // Icona della home
            label: 'Home',           // Testo 'Home' sotto l'icona
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),  // Icona della chat
            label: 'Chat',           // Testo 'Chat'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),  // Icona per le prenotazioni
            label: 'Prenotazioni',          // Testo 'Prenotazioni'
          ),
        ],

        // Stile della BottomNavigationBar
        backgroundColor: const Color(0xFF4D7881),  // Colore di sfondo della BottomNavigationBar
        selectedItemColor: Colors.white,           // Colore delle icone selezionate
        unselectedItemColor: Colors.white54,       // Colore delle icone non selezionate
      ),
    );
  }
}
