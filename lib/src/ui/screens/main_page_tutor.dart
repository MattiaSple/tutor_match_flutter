import 'package:flutter/material.dart';
import 'package:tutormatch/src/ui/screens/home_tutor.dart';
import 'package:tutormatch/src/ui/screens/prenotazioni_page.dart';
import 'package:tutormatch/src/ui/screens/chat_page.dart';
import 'package:tutormatch/src/ui/screens/profilo_page.dart';

import 'calendario_tutor_page.dart';

// Classe principale per la schermata principale del tutor
class MainPageTutor extends StatefulWidget {
  const MainPageTutor({super.key}); // Costruttore

  @override
  _MainPageTutorState createState() => _MainPageTutorState(); // Stato associato
}

class _MainPageTutorState extends State<MainPageTutor> {
  int _selectedIndex = 2; // Indice della pagina corrente selezionata

  @override
  Widget build(BuildContext context) {
    // Recupera gli argomenti passati alla schermata (userId e ruolo)
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final String userId = arguments['userId']; // ID dell'utente
    final bool ruolo = arguments['ruolo']; // Ruolo dell'utente (tutor/studente)

    // Definizione delle pagine disponibili per il tutor
    final List<Widget> _tutorPages = [
      ProfiloPage(userId: userId, ruolo: ruolo),      // Pagina Profilo
      CalendarioTutorPage(tutorId: userId),           // Pagina Calendario
      HomeTutor(userId: userId, ruolo: ruolo),        // Pagina Home Tutor
      ChatPage(userId: userId, ruolo: ruolo),         // Pagina Chat
      PrenotazioniPage(userId: userId, ruolo: ruolo), // Pagina Prenotazioni
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
        children: _tutorPages,  // Lista delle pagine disponibili
      ),

      // BottomNavigationBar che consente al tutor di cambiare pagina
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Imposta il tipo per evitare il comportamento predefinito
        currentIndex: _selectedIndex,  // Indice corrente
        onTap: _onItemTapped,  // Chiama la funzione _onItemTapped quando si tocca un elemento
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profilo', // Elemento per accedere alla pagina Profilo
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendario', // Elemento per accedere alla pagina Calendario
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
            icon: Icon(Icons.book_online),
            label: 'Prenotazioni', // Elemento per accedere alla pagina Prenotazioni
          ),
        ],

        // Stile della BottomNavigationBar
        backgroundColor: const Color(0xFF4D7881),  // Colore di sfondo della barra inferiore
        selectedItemColor: Colors.white,           // Colore dell'elemento selezionato
        unselectedItemColor: Colors.white54,       // Colore degli elementi non selezionati
      ),
    );
  }
}
