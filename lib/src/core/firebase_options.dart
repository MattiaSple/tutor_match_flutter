// File generato automaticamente dalla FlutterFire CLI per configurare Firebase.
// ignore_for_file: type=lint

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions; // Importa FirebaseOptions per configurare Firebase.
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform; // Importa costanti e funzioni per determinare la piattaforma.

/// Classe per gestire le configurazioni di Firebase su diverse piattaforme.
class DefaultFirebaseOptions {
  // Metodo per ottenere le opzioni di configurazione in base alla piattaforma corrente.
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // Lancia un'eccezione se si tenta di utilizzare Firebase su web senza configurazione.
      throw UnsupportedError(
        'DefaultFirebaseOptions non è configurato per il web. '
            'Puoi configurarlo eseguendo nuovamente FlutterFire CLI.',
      );
    }
    // Seleziona la configurazione in base alla piattaforma di destinazione.
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android; // Ritorna la configurazione per Android.
      case TargetPlatform.iOS:
        return ios; // Ritorna la configurazione per iOS.
      case TargetPlatform.macOS:
      // Lancia un'eccezione per macOS se non è configurato.
        throw UnsupportedError(
          'DefaultFirebaseOptions non è configurato per macOS. '
              'Puoi configurarlo eseguendo nuovamente FlutterFire CLI.',
        );
      case TargetPlatform.windows:
      // Lancia un'eccezione per Windows se non è configurato.
        throw UnsupportedError(
          'DefaultFirebaseOptions non è configurato per Windows. '
              'Puoi configurarlo eseguendo nuovamente FlutterFire CLI.',
        );
      case TargetPlatform.linux:
      // Lancia un'eccezione per Linux se non è configurato.
        throw UnsupportedError(
          'DefaultFirebaseOptions non è configurato per Linux. '
              'Puoi configurarlo eseguendo nuovamente FlutterFire CLI.',
        );
      default:
      // Lancia un'eccezione se la piattaforma non è supportata.
        throw UnsupportedError(
          'DefaultFirebaseOptions non è supportato per questa piattaforma.',
        );
    }
  }

  // Configurazione per Firebase su Android.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD8YbDPuX4u4O6dlNA-jpocr2VG0SbvxBk', // Chiave API per autenticazione e servizi Firebase.
    appId: '1:484443841980:android:f257af22b01489e159b7b9', // ID dell'app per Firebase.
    messagingSenderId: '484443841980', // ID per il servizio di messaggistica Firebase.
    projectId: 'tutormatch-a7439', // ID del progetto Firebase.
    databaseURL: 'https://tutormatch-a7439-default-rtdb.europe-west1.firebasedatabase.app', // URL del database in tempo reale.
    storageBucket: 'tutormatch-a7439.appspot.com', // URL del bucket di archiviazione.
  );

  // Configurazione per Firebase su iOS.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDZXXIvSCYLKy48A59rk-synC0KjuK8ips', // Chiave API per autenticazione e servizi Firebase su iOS.
    appId: '1:484443841980:ios:c54ad2f831d35ca459b7b9', // ID dell'app per Firebase su iOS.
    messagingSenderId: '484443841980', // ID per il servizio di messaggistica Firebase su iOS.
    projectId: 'tutormatch-a7439', // ID del progetto Firebase.
    databaseURL: 'https://tutormatch-a7439-default-rtdb.europe-west1.firebasedatabase.app', // URL del database in tempo reale.
    storageBucket: 'tutormatch-a7439.appspot.com', // URL del bucket di archiviazione.
    iosBundleId: 'com.example.tutormatch', // Bundle ID dell'app iOS.
  );
}
