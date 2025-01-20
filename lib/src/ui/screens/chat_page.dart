import 'package:flutter/material.dart'; // Importa il framework per costruire l'interfaccia utente.
import 'package:provider/provider.dart'; // Per la gestione dello stato tramite Provider.
import 'package:tutormatch/src/viewmodels/chat_view_model.dart'; // ViewModel per la gestione delle chat.
import 'in_chat_page.dart'; // Pagina per visualizzare i messaggi all'interno di una chat.

class ChatPage extends StatefulWidget {
  final String userId; // ID dell'utente corrente.
  final bool ruolo; // Ruolo dell'utente (true = tutor, false = studente).

  const ChatPage({required this.userId, required this.ruolo, super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
    // Utilizza un callback per inizializzare l'ascolto delle chat dopo il primo frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatViewModel>(context, listen: false).listenToChats(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatViewModel = Provider.of<ChatViewModel>(context); // Recupera il ViewModel delle chat.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Le tue chat'), // Titolo della pagina.
        centerTitle: true, // Centra il titolo nell'AppBar.
        automaticallyImplyLeading: false, // Nasconde il pulsante di navigazione indietro.
      ),
      body: chatViewModel.isLoading
          ? const Center(child: CircularProgressIndicator()) // Mostra un indicatore di caricamento se i dati sono in caricamento.
          : ListView.builder(
        itemCount: chatViewModel.chats.length, // Numero di chat disponibili.
        itemBuilder: (context, index) {
          final chat = chatViewModel.chats[index]; // Recupera la chat corrente.

          // Determina il nome dell'altro partecipante alla chat.
          final otherParticipantName = chat.participantsNames.firstWhere(
                (name) => name != chatViewModel.loggedUserName,
            orElse: () => 'Sconosciuto',
          );

          // Verifica se ci sono messaggi non letti.
          final isUnread = chat.lastMessage.unreadBy.contains(chatViewModel.loggedUserEmail);

          return Container(
            // Cambia colore se ci sono messaggi non letti.
            color: isUnread ? Theme.of(context).primaryColor : Colors.transparent,
            child: ListTile(
              title: Text(otherParticipantName), // Mostra il nome dell'altro partecipante.
              subtitle: Text(
                chat.lastMessage?.text ?? "Nessun messaggio", // Mostra l'ultimo messaggio o un messaggio di default.
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(chat.subject), // Mostra il soggetto della chat.
                  IconButton(
                    icon: const Icon(Icons.delete), // Pulsante per eliminare la chat.
                    onPressed: () async {
                      // Mostra un dialog di conferma per l'eliminazione.
                      final confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Conferma eliminazione'),
                          content: const Text('Sei sicuro di voler eliminare questa chat?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false), // Chiude il dialog senza confermare.
                              child: const Text('Annulla'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true), // Chiude il dialog confermando.
                              child: const Text('Elimina'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        // Elimina la chat se confermato.
                        chatViewModel.eliminaChat(chat.id);
                      }
                    },
                  ),
                ],
              ),
              onTap: () {
                // Naviga alla pagina della chat selezionata.
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
