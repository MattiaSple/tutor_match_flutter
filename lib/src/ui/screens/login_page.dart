import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/viewmodels/auth_view_model.dart'; // Importa il ViewModel per la gestione dell'autenticazione.

class LoginPage extends StatefulWidget {
  const LoginPage({super.key}); // Costruttore per la pagina di login.

  @override
  _LoginPageState createState() => _LoginPageState(); // Crea lo stato per la pagina di login.
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController(); // Controller per il campo email.
  final TextEditingController _passwordController = TextEditingController(); // Controller per il campo password.
  String errorMessage = ''; // Messaggio di errore visualizzato all'utente.

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context); // Ottieni il ViewModel per gestire l'autenticazione.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'), // Titolo della pagina.
        centerTitle: true, // Centra il titolo nella barra dell'app.
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente gli elementi.
              crossAxisAlignment: CrossAxisAlignment.start, // Allinea gli elementi a sinistra.
              children: [
                const SizedBox(height: 40), // Spazio all'inizio per migliorare il layout.
                const Center(
                  child: Text(
                    'Accedi al tuo account', // Testo principale della pagina.
                    style: TextStyle(
                      fontSize: 28, // Dimensione del testo.
                      fontWeight: FontWeight.bold, // Testo in grassetto.
                      color: Color(0xFF4D7881), // Colore personalizzato.
                    ),
                  ),
                ),
                const SizedBox(height: 40), // Spazio tra il titolo e il campo email.

                // Campo email
                TextField(
                  controller: _emailController, // Collega il controller al campo.
                  decoration: InputDecoration(
                    labelText: 'Email', // Testo descrittivo nel campo.
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0), // Angoli arrotondati.
                    ),
                    filled: true, // Sfondo colorato.
                    fillColor: Colors.grey[200], // Colore dello sfondo.
                  ),
                ),
                const SizedBox(height: 20), // Spazio tra il campo email e password.

                // Campo password
                TextField(
                  controller: _passwordController, // Collega il controller al campo.
                  obscureText: true, // Nasconde il testo per la password.
                  decoration: InputDecoration(
                    labelText: 'Password', // Testo descrittivo nel campo.
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0), // Angoli arrotondati.
                    ),
                    filled: true, // Sfondo colorato.
                    fillColor: Colors.grey[200], // Colore dello sfondo.
                  ),
                ),
                const SizedBox(height: 20), // Spazio tra il campo password e il messaggio di errore.

                // Messaggio di errore
                if (errorMessage.isNotEmpty) // Mostra il messaggio di errore se non è vuoto.
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      errorMessage, // Messaggio di errore.
                      style: const TextStyle(color: Colors.red, fontSize: 14), // Stile del messaggio.
                    ),
                  ),

                // Bottone di login
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          // Effettua il login con email e password.
                          await authViewModel.signInWithEmailAndPassword(
                            _emailController.text.trim(), // Email inserita dall'utente.
                            _passwordController.text.trim(), // Password inserita dall'utente.
                          );

                          // Recupera l'ID utente autenticato.
                          final userId = authViewModel.currentUser?.uid;

                          if (userId != null) {
                            // Recupera il ruolo dell'utente (tutor o studente).
                            bool ruolo = await authViewModel.getUserRole(userId);

                            // Reindirizza l'utente alla schermata corretta in base al ruolo.
                            if (ruolo) {
                              Navigator.pushReplacementNamed(
                                context,
                                '/main_page_tutor', // Schermata principale per i tutor.
                                arguments: {
                                  'userId': userId,
                                  'ruolo': ruolo
                                },
                              );
                            } else {
                              Navigator.pushReplacementNamed(
                                context,
                                '/main_page_studente', // Schermata principale per gli studenti.
                                arguments: {
                                  'userId': userId,
                                  'ruolo': ruolo
                                },
                              );
                            }
                          } else {
                            // Mostra un messaggio di errore se l'ID utente non è disponibile.
                            setState(() {
                              errorMessage = 'Errore durante il login. Riprova.';
                            });
                          }
                        } catch (e) {
                          // Gestisce eventuali errori durante il login.
                          setState(() {
                            errorMessage = 'Errore durante il login. Riprova.';
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0), // Angoli arrotondati.
                        ),
                        backgroundColor: const Color(0xFF4D7881), // Colore di sfondo del bottone.
                      ),
                      child: const Text(
                        'Accedi', // Testo nel bottone.
                        style: TextStyle(fontSize: 18, color: Colors.white), // Stile del testo.
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
