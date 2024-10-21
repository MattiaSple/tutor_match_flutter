import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/viewmodels/auth_view_model.dart'; // Assicurati che questa classe esista
import 'package:tutormatch/src/ui/screens/main_page.dart'; // Schermata principale
import 'package:tutormatch/src/ui/screens/login_page.dart'; // Schermata di login
import 'package:firebase_core/firebase_core.dart';
import 'package:tutormatch/src/core/firebase_options.dart'; // Configurazione Firebase

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Inizializza Firebase
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Registriamo il ViewModel di autenticazione qui
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp(
        title: 'TutorMatch',
        theme: ThemeData(
          primaryColor: const Color(0xFF4D7881), // Colore principale
          scaffoldBackgroundColor: Colors.white, // Sfondo bianco
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF4D7881), // Colore dell'appBar
            foregroundColor: Colors.white, // Colore del testo dell'appBar
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4D7881),
              foregroundColor: Colors.white
            )
          ),
        ),

        initialRoute: '/',
        routes: {
          '/': (context) => const MainPage(),
          '/login': (context) => const LoginPage(),
        },
      ),
    );
  }
}
