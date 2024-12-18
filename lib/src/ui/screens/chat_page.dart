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
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: chatViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: chatViewModel.chats.length,
        itemBuilder: (context, index) {
          final chat = chatViewModel.chats[index];
          final otherParticipantName = chat.participantsNames.firstWhere(
                (name) => name != chatViewModel.loggedUserName,
            orElse: () => 'Sconosciuto',
          );

          final isUnread = chat.lastMessage.unreadBy.contains(chatViewModel.loggedUserEmail);

          return Container(
            color: isUnread ? Colors.yellow : Colors.transparent,
            child: ListTile(
              title: Text(otherParticipantName),
              subtitle: Text(
                chat.lastMessage?.text ?? "Nessun messaggio",
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(chat.subject),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Conferma eliminazione'),
                          content: const Text('Sei sicuro di voler eliminare questa chat?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Annulla'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Elimina'),
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
                    builder: (context) => InChatPage(
                      chatId: chat.id,
                      userId: widget.userId,
                      isUnread: isUnread,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
