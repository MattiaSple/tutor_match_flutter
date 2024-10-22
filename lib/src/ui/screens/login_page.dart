import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/viewmodels/auth_view_model.dart'; // Importa il ViewModel

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context); // Ottieni il ViewModel

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true, // Titolo centrato
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Accedi al tuo account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4D7881),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Campo email
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 20),

            // Campo password
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 20),

            // Messaggio di errore
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),

            // Bottone di login
            Center(
              child: SizedBox(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      // Effettua il login
                      await authViewModel.signInWithEmailAndPassword(
                        _emailController.text,
                        _passwordController.text,
                      );

                      // Recupera l'ID utente
                      final userId = authViewModel.currentUser?.uid;

                      if (userId != null) {
                        // Recupera il ruolo dell'utente
                        bool isTutor = await authViewModel.getUserRole(userId);

                        // In base al ruolo, reindirizza alla schermata corretta
                        if (isTutor) {
                          Navigator.pushReplacementNamed(
                            context,
                            '/home_tutor',
                            arguments: userId, // Passa l'ID utente
                          );
                        } else {
                          Navigator.pushReplacementNamed(
                            context,
                            '/home_studente',
                            arguments: userId, // Passa l'ID utente
                          );
                        }

                      } else {
                        setState(() {
                          errorMessage = 'Errore durante il login. Riprova.';
                        });
                      }
                    } catch (e) {
                      setState(() {
                        errorMessage = 'Errore durante il login. Riprova.';
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    backgroundColor: const Color(0xFF4D7881),
                  ),
                  child: const Text(
                    'Accedi',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
