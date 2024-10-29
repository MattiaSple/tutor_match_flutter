import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:tutormatch/src/viewmodels/in_chat_view_model.dart';

class InChatPage extends StatefulWidget {
  final String chatId;
  final String userId;

  const InChatPage({required this.chatId, required this.userId, Key? key}) : super(key: key);

  @override
  _InChatPageState createState() => _InChatPageState();
}

class _InChatPageState extends State<InChatPage> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();
  bool _messagesLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_messagesLoaded) {
      _messagesLoaded = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _loadMessages();
      });
    }
  }

  void _loadMessages() {
    final inChatViewModel = Provider.of<InChatViewModel>(context, listen: false);
    inChatViewModel.loadMessages(widget.chatId);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (MediaQuery.of(context).viewInsets.bottom > 0) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
      ),
      body: Consumer<InChatViewModel>(
        builder: (context, inChatViewModel, child) {
          if (inChatViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (inChatViewModel.messagesLoaded) {
              _scrollToBottom();
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: inChatViewModel.messages.length,
                    itemBuilder: (context, index) {
                      final message = inChatViewModel.messages[index];

                      return FutureBuilder<String>(
                        future: inChatViewModel.getEmail(widget.userId),
                        builder: (context, snapshot) {
                          final senderEmail = snapshot.data ?? '';
                          bool isMine = message.senderId == senderEmail;

                          return Align(
                            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.only(
                                top: 5,
                                bottom: 5,
                                left: isMine ? 50 : 10,
                                right: isMine ? 10 : 50,
                              ),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isMine ? Colors.blueAccent : Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    senderEmail,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isMine ? Colors.white70 : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    message.text,
                                    style: TextStyle(
                                      color: isMine ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    DateTime.fromMillisecondsSinceEpoch(message.timestamp).toString(),
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: const InputDecoration(hintText: "Scrivi un messaggio"),
                          onTap: _scrollToBottom,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          final text = messageController.text;
                          if (text.isNotEmpty) {
                            await inChatViewModel.sendMessage(widget.chatId, widget.userId, text);
                            messageController.clear();
                            _scrollToBottom();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
