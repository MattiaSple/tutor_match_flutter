import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/viewmodels/chat_view_model.dart';
import 'in_chat_page.dart';

class ChatPage extends StatelessWidget {
  final String userId;
  final bool ruolo;

  const ChatPage({required this.userId, required this.ruolo, super.key});

  @override
  Widget build(BuildContext context) {
    final chatViewModel = Provider.of<ChatViewModel>(context);

    // Carica le chat solo se non sono già state caricate
    if (!chatViewModel.hasLoadedChats && !chatViewModel.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        chatViewModel.loadChatsWithUserInfo(userId); // Inizia il caricamento delle chat
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

          return ListTile(
            title: Text(otherParticipantName),
            subtitle: Text(chat.lastMessage),
            trailing: Text(chat.subject),
            onTap: () {
              // Naviga verso la pagina di chat con i messaggi
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InChatPage(chatId: chat.id, userId: userId),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
