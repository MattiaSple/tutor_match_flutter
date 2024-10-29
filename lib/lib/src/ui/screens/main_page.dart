import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/ragazzi.png', // Assicurati di avere il logo nella cartella assets
              width: MediaQuery.of(context).size.width * 0.7,  // Larghezza del 70% dello schermo
              height: MediaQuery.of(context).size.height * 0.5, // Altezza del 50% dello schermo
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            const Text(
              'Benvenuto su TutorMatch',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Accedi'),
            ),
          ],
        ),
      ),
    );
  }
}
