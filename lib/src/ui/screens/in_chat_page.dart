import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/viewmodels/in_chat_view_model.dart';
import '../../models/messaggio.dart';

class InChatPage extends StatefulWidget {
  final String chatId;
  final String userId;
  final bool isUnread;

  const InChatPage({
    required this.chatId,
    required this.userId,
    required this.isUnread,
    Key? key,
  }) : super(key: key);
  @override
  _InChatPageState createState() => _InChatPageState();
}

class _InChatPageState extends State<InChatPage> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? userEmail;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserEmail(); // Carica l'email all'inizio

    // Aggiungi un listener al focusNode per rilevare quando la tastiera si apre
    _focusNode.addListener(_onKeyboardOpened);
  }

  void _onKeyboardOpened() {
    if (_focusNode.hasFocus) {
      Future.delayed(const Duration(seconds: 1), () {
        _scrollToBottom();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    messageController.dispose();

    // Rimuovi il listener dal focusNode
    _focusNode.removeListener(_onKeyboardOpened);
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadUserEmail() async {
    final inChatViewModel = Provider.of<InChatViewModel>(
        context, listen: false);
    userEmail = await inChatViewModel.getEmail(widget.userId);
    setState(() {}); // Aggiorna lo stato una volta caricata l'email
  }

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
    final inChatViewModel = Provider.of<InChatViewModel>(
        context, listen: false);

    // Verifica che userEmail non sia null
    if (userEmail == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.isUnread) {
      inChatViewModel.unreadBySetToFalse(widget.chatId, userEmail!);
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Chat"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Messaggio>>(
              stream: inChatViewModel.getMessagesStream(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: Text("Nessun messaggio."));
                }

                final messages = snapshot.data!;
                WidgetsBinding.instance.addPostFrameCallback((_) =>
                    _scrollToBottom());
                inChatViewModel.unreadBySetToFalse(widget.chatId, userEmail!);

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    bool isMine = message.senderId == userEmail;

                    return FutureBuilder<String>(
                      future: inChatViewModel.getSenderNameByEmail(
                          message.senderId),
                      builder: (context, snapshot) {
                        final senderName = snapshot.data ?? '';
                        return Align(
                          alignment: isMine ? Alignment.centerRight : Alignment
                              .centerLeft,
                          child: Container(
                            margin: EdgeInsets.only(
                              top: 5,
                              bottom: 5,
                              left: isMine ? 50 : 10,
                              right: isMine ? 10 : 50,
                            ),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMine ? Colors.blueAccent : Colors
                                  .grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: isMine ? CrossAxisAlignment
                                  .end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  senderName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isMine ? Colors.white70 : Colors
                                        .black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  message.text,
                                  style: TextStyle(
                                    color: isMine ? Colors.white : Colors
                                        .black87,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      message.timestamp).toString(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isMine ? Colors.white60 : Colors
                                        .black54,
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
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: _focusNode,
                    controller: messageController,
                    decoration: const InputDecoration(
                        hintText: "Scrivi un messaggio"),
                    onTap: () {
                      FocusScope.of(context).requestFocus(_focusNode);
                      _scrollToBottom();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = messageController.text;
                    if (text.isNotEmpty) {
                      await inChatViewModel.sendMessage(
                          widget.chatId, widget.userId, text);
                      messageController.clear();
                      _scrollToBottom();
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
