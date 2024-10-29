import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/viewmodels/chat_view_model.dart';
import 'package:tutormatch/src/core/firebase_util.dart'; // Importa FirebaseUtil per ottenere l'email e il nome
import 'in_chat_page.dart';

class ChatPage extends StatelessWidget {
  final String userId;
  final bool ruolo;

  const ChatPage({required this.userId, required this.ruolo, super.key});

  Future<void> _loadChatsWithUserInfo(BuildContext context, ChatViewModel chatViewModel) async {
    try {
      // Recupera l'email e il nome completo dell'utente
      String email = await FirebaseUtil().getEmailByUserId(userId);
      String fullName = await FirebaseUtil().getNomeDaRef(userId); // nome completo dell'utente
      print("Email trovata: $email, Nome completo: $fullName");

      // Carica le chat usando l'email
      chatViewModel.loadAllChats(email, fullName); // Passiamo anche il nome completo per il confronto
      chatViewModel.setChatsLoaded(true); // Imposta il flag dopo il caricamento iniziale
    } catch (e) {
      print("Errore nel caricamento delle informazioni dell'utente: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatViewModel = Provider.of<ChatViewModel>(context);

    // Carica le chat solo se non sono già state caricate
    if (!chatViewModel.hasLoadedChats && !chatViewModel.isLoading) {
      print("ChatPage: Caricamento delle chat avviato per $userId");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadChatsWithUserInfo(context, chatViewModel); // Carica le chat una sola volta
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Le tue chat'),
      ),
      body: chatViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: chatViewModel.chats.length,
        itemBuilder: (context, index) {
          final chat = chatViewModel.chats[index];
          // Trova il nome dell'altro partecipante
          String otherParticipantName = chat.participantsNames
              .firstWhere((name) => name != chatViewModel.loggedUserName, orElse: () => 'Sconosciuto');

          print("ChatPage: Chat visualizzata - ${chat.subject}, Altro partecipante: $otherParticipantName");

          return ListTile(
            title: Text(chat.subject),
            subtitle: Text(chat.lastMessage),
            trailing: Text(otherParticipantName), // Visualizza il nome dell'altro partecipante
            onTap: () {
              // Naviga verso la pagina di chat con i messaggi
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InChatPage(chatId: chat.id, userId: userId), // Passa userId qui
                ),
              );
            },
          );
        },
      ),
    );
  }
}
