import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/viewmodels/chat_view_model.dart';
import 'in_chat_page.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final bool ruolo;

  const ChatPage({required this.userId, required this.ruolo, super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
    // Chiama listenToChats una sola volta, quando la pagina è creata
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatViewModel>(context, listen: false).listenToChats(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatViewModel = Provider.of<ChatViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Le tue chat'),
        centerTitle: true, // Centra il titolo
        automaticallyImplyLeading: false, // Rimuove la freccia indietro
      ),
      body: chatViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: chatViewModel.chats.length,
        itemBuilder: (context, index) {
          final chat = chatViewModel.chats[index];
          String otherParticipantName = chat.participantsNames
              .firstWhere((name) => name != chatViewModel.loggedUserName, orElse: () => 'Sconosciuto');

          return ListTile(
            title: Text(otherParticipantName),
            subtitle: Text(chat.lastMessage),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(chat.subject),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    final confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Conferma eliminazione'),
                        content: Text('Sei sicuro di voler eliminare questa chat?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Annulla'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('Elimina'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      chatViewModel.eliminaChat(chat.id);
                    }
                  },
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InChatPage(chatId: chat.id, userId: widget.userId),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
