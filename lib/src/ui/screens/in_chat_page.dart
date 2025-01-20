import 'package:flutter/material.dart'; // Importa le librerie necessarie per l'interfaccia utente.
import 'package:provider/provider.dart'; // Importa il pacchetto Provider per la gestione dello stato.
import 'package:tutormatch/src/viewmodels/in_chat_view_model.dart'; // Importa il ViewModel per gestire la logica della chat.
import '../../models/messaggio.dart'; // Importa il modello per rappresentare un messaggio.

class InChatPage extends StatefulWidget {
  final String chatId; // ID della chat corrente.
  final String userId; // ID dell'utente corrente.
  final bool isUnread; // Indica se ci sono messaggi non letti nella chat.

  const InChatPage({
    required this.chatId,
    required this.userId,
    required this.isUnread,
    Key? key,
  }) : super(key: key); // Costruttore della pagina.

  @override
  _InChatPageState createState() => _InChatPageState(); // Crea lo stato della pagina.
}

class _InChatPageState extends State<InChatPage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController(); // Controlla lo scorrimento dei messaggi.
  final TextEditingController messageController = TextEditingController(); // Controlla l'input del messaggio.
  final FocusNode _focusNode = FocusNode(); // Gestisce il focus sul campo di input.
  String? userEmail; // Memorizza l'email dell'utente corrente.

  @override
  bool get wantKeepAlive => true; // Mantiene lo stato della pagina attivo.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Aggiunge un osservatore per eventi del ciclo di vita dell'app.
    _loadUserEmail(); // Carica l'email dell'utente.

    // Aggiunge un listener per rilevare quando la tastiera si apre.
    _focusNode.addListener(_onKeyboardOpened);
  }

  void _onKeyboardOpened() {
    if (_focusNode.hasFocus) {
      // Scorre automaticamente in fondo alla lista dei messaggi dopo un leggero ritardo.
      Future.delayed(const Duration(seconds: 1), () {
        _scrollToBottom();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Rimuove l'osservatore.
    _scrollController.dispose(); // Rilascia le risorse del controller di scorrimento.
    messageController.dispose(); // Rilascia le risorse del controller di input.

    // Rimuove il listener dal focusNode e rilascia le risorse.
    _focusNode.removeListener(_onKeyboardOpened);
    _focusNode.dispose();
    super.dispose();
  }

  // Carica l'email dell'utente utilizzando il ViewModel.
  Future<void> _loadUserEmail() async {
    final inChatViewModel = Provider.of<InChatViewModel>(context, listen: false);
    userEmail = await inChatViewModel.getEmail(widget.userId); // Recupera l'email associata all'ID utente.
    setState(() {}); // Aggiorna lo stato una volta caricata l'email.
  }

  // Scorre automaticamente in fondo alla lista dei messaggi.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 1),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final inChatViewModel = Provider.of<InChatViewModel>(context, listen: false);

    // Mostra un indicatore di caricamento se l'email dell'utente non è ancora disponibile.
    if (userEmail == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Segna i messaggi come letti se ci sono messaggi non letti.
    if (widget.isUnread) {
      inChatViewModel.unreadBySetToFalse(widget.chatId, userEmail!);
    }

    return Scaffold(
      resizeToAvoidBottomInset: true, // Evita sovrapposizioni con la tastiera.
      appBar: AppBar(
        title: const Text("Chat"), // Titolo della pagina.
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Messaggio>>(
              stream: inChatViewModel.getMessagesStream(widget.chatId), // Stream per i messaggi in tempo reale.
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  // Mostra un messaggio predefinito se non ci sono dati.
                  return const Center(child: Text("Nessun messaggio."));
                }

                final messages = snapshot.data!; // Recupera i messaggi dallo stream.
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom()); // Scorre automaticamente in fondo.
                inChatViewModel.unreadBySetToFalse(widget.chatId, userEmail!); // Aggiorna lo stato dei messaggi non letti.

                return ListView.builder(
                  controller: _scrollController, // Gestisce lo scorrimento.
                  itemCount: messages.length, // Numero totale di messaggi.
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    bool isMine = message.senderId == userEmail; // Determina se il messaggio è dell'utente corrente.
                    String time = DateTime.fromMillisecondsSinceEpoch(message.timestamp).toString();

                    // Separiamo la stringa per ottenere solo la parte desiderata (anno, mese, giorno, ore, minuti)
                    List<String> parts = time.split(' '); // Dividi la data e l'ora in base agli spazi

                    String formattedTime = parts[0] + ' ' + parts[1].substring(0, 5); // Aggiungi data e ora (senza secondi e millisecondi)

                    return FutureBuilder<String>(
                      future: inChatViewModel.getSenderNameByEmail(message.senderId), // Recupera il nome del mittente.
                      builder: (context, snapshot) {
                        final senderName = snapshot.data ?? ''; // Nome del mittente o stringa vuota.
                        return Align(
                          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft, // Allinea il messaggio.
                          child: Container(
                            margin: EdgeInsets.only(
                              top: 5,
                              bottom: 5,
                              left: isMine ? 50 : 10,
                              right: isMine ? 10 : 50,
                            ),
                            padding: const EdgeInsets.all(10), // Spazio interno del messaggio.
                            decoration: BoxDecoration(
                              color: isMine ? Colors.blueAccent : Colors.grey[300], // Colore del messaggio.
                              borderRadius: BorderRadius.circular(10), // Bordo arrotondato.
                            ),
                            child: Column(
                              crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start, // Allinea il contenuto.
                              children: [
                                Text(
                                  senderName, // Mostra il nome del mittente.
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isMine ? Colors.white70 : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  message.text, // Mostra il contenuto del messaggio.
                                  style: TextStyle(
                                    color: isMine ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  formattedTime, // Mostra data e ora del messaggio.
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isMine ? Colors.white60 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0), // Spazio intorno al campo di input.
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: _focusNode, // Focus sul campo di input.
                    controller: messageController, // Controlla il testo inserito.
                    decoration: const InputDecoration(hintText: "Scrivi un messaggio"), // Placeholder per il campo di input.
                    onTap: () {
                      FocusScope.of(context).requestFocus(_focusNode); // Porta il focus sul campo di input.
                      _scrollToBottom(); // Scorre in fondo.
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send), // Icona di invio.
                  onPressed: () async {
                    final text = messageController.text; // Recupera il testo del messaggio.
                    if (text.isNotEmpty) {
                      await inChatViewModel.sendMessage(widget.chatId, widget.userId, text); // Invia il messaggio.
                      messageController.clear(); // Pulisce il campo di input.
                      _scrollToBottom(); // Scorre in fondo dopo l'invio.
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
