import 'package:flutter/material.dart';

class HomeStudente extends StatefulWidget {
  const HomeStudente({super.key});

  @override
  _HomeStudenteState createState() => _HomeStudenteState();
}

class _HomeStudenteState extends State<HomeStudente> {
  int _selectedIndex = 0;

  // Definisci le pagine che saranno navigate dalla BottomNavigationBar
  static const List<Widget> _pages = <Widget>[
    Center(child: Text('Pagina Home Studente', style: TextStyle(fontSize: 24))),
    Center(child: Text('Profilo Studente', style: TextStyle(fontSize: 24))),
    Center(child: Text('Impostazioni', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Studente'),
      ),
      body: _pages[_selectedIndex], // Mostra la pagina selezionata
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
        selectedItemColor: const Color(0xFF4D7881), // Colore della voce selezionata
        onTap: _onItemTapped, // Aggiorna l'indice della pagina
      ),
    );
  }
}
