import 'package:flutter/material.dart';
import 'package:tutormatch/src/ui/screens/home_studente.dart';
import 'package:tutormatch/src/ui/screens/prenotazioni_page.dart';
import 'package:tutormatch/src/ui/screens/chat_page.dart';
import 'package:tutormatch/src/ui/screens/profilo_page.dart';
import 'package:tutormatch/src/ui/screens/ricerca_tutor_page.dart';

class MainPageStudente extends StatefulWidget {
  const MainPageStudente({super.key});

  @override
  _MainPageStudenteState createState() => _MainPageStudenteState();
}

class _MainPageStudenteState extends State<MainPageStudente> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Recupera gli argomenti passati (userId e ruolo)
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final String userId = arguments['userId'];
    final bool ruolo = arguments['ruolo'];

    // Le pagine da mostrare nell'IndexedStack, passa userId e ruolo a ciascuna schermata
    final List<Widget> _studentPages = [
      ProfiloPage(userId: userId, ruolo: ruolo),         // Pagina Profilo
      PrenotazioniPage(userId: userId, ruolo: ruolo),    // Pagina Prenotazioni
      HomeStudente(userId: userId, ruolo: ruolo),        // Pagina Home Studente
      ChatPage(userId: userId, ruolo: ruolo),            // Pagina Chat
      RicercaTutorPage(userId: userId, ruolo: ruolo),    // Pagina Ricerca Tutor
    ];

    // Funzione per cambiare pagina
    void _onItemTapped(int index) {
      if (_selectedIndex != index) {
        setState(() {
          _selectedIndex = index;  // Cambia pagina solo se l'indice è diverso
        });
      }
      // Se l'indice è lo stesso, non fare nulla
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,  // Usa _selectedIndex per decidere quale pagina mostrare
        children: _studentPages,  // Le pagine disponibili sono definite in _studentPages
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,  // Imposta il tipo per evitare il comportamento di Material 3
        currentIndex: _selectedIndex,  // Imposta l'indice corrente sulla barra inferiore
        onTap: _onItemTapped,  // Chiama _onItemTapped quando l'utente tocca un'icona
        items: const <BottomNavigationBarItem>[  // Definisce le icone e i label per la barra
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profilo'),
          BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Prenotazioni'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Ricerca Tutor'),
        ],
        backgroundColor: const Color(0xFF4D7881),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
      ),
    );
  }
}
