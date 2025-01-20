import 'package:flutter/material.dart';

// Classe principale per la pagina iniziale
class MainPage extends StatelessWidget {
  const MainPage({super.key}); // Costruttore per la classe.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold fornisce una struttura di base per la schermata.
      body: Center(
        // Centra il contenuto all'interno della schermata.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Allinea gli elementi verticalmente al centro.
          children: [
            Image.asset(
              'images/ragazzi.png', // Percorso dell'immagine da mostrare.
              width: MediaQuery.of(context).size.width * 0.7, // Imposta la larghezza come il 70% della larghezza dello schermo.
              height: MediaQuery.of(context).size.height * 0.5, // Imposta l'altezza come il 50% dell'altezza dello schermo.
              fit: BoxFit.contain, // L'immagine si adatta mantenendo le proporzioni.
            ),
            const SizedBox(height: 30), // Spazio verticale tra l'immagine e il testo.
            const Text(
              'Benvenuto su TutorMatch', // Testo di benvenuto per l'utente.
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Stile del testo: grande e in grassetto.
            ),
            const SizedBox(height: 40), // Spazio verticale tra il testo e il bottone.
            ElevatedButton(
              onPressed: () {
                // Naviga alla schermata di login quando si preme il bottone.
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Accedi'), // Testo all'interno del bottone.
            ),
          ],
        ),
      ),
    );
  }
}
