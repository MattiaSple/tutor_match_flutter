import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/ui/screens/main_page_studente.dart';
import 'package:tutormatch/src/ui/screens/main_page_tutor.dart';
import 'package:tutormatch/src/viewmodels/annuncio_view_model.dart';
import 'package:tutormatch/src/viewmodels/auth_view_model.dart';
import 'package:tutormatch/src/ui/screens/main_page.dart';
import 'package:tutormatch/src/ui/screens/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tutormatch/src/core/firebase_options.dart';
import 'package:tutormatch/src/viewmodels/home_studente_view_model.dart';
import 'package:tutormatch/src/viewmodels/prenotazioni_view_model.dart';
import 'package:tutormatch/src/viewmodels/profilo_view_model.dart';

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
        ChangeNotifierProvider(create: (_) => AnnuncioViewModel()),
        ChangeNotifierProvider(create: (_) => PrenotazioniViewModel()),
        ChangeNotifierProvider(create: (_) => ProfiloViewModel()),
        ChangeNotifierProvider(create: (_) => HomeStudenteViewModel())
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
          // Usa le nuove schermate con IndexedStack e BottomNavigationBar
          "/main_page_tutor": (context) => const MainPageTutor(),
          "/main_page_studente": (context) => const MainPageStudente(),
        },
      ),
    );
  }
}
