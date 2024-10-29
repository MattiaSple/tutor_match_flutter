class Chat {
  final String id;
  final String subject;
  final String lastMessage;
  final List<String> participantsNames;

  Chat({
    required this.id,
    required this.subject,
    required this.lastMessage,
    required this.participantsNames,
  });

  // Factory method per creare una Chat da Firebase
  factory Chat.fromMap(String id, Map<dynamic, dynamic> data) {
    return Chat(
      id: id,
      subject: data['subject'] ?? '',
      lastMessage: data['lastMessage']['text'] ?? '',
      participantsNames: List<String>.from(data['participantsNames'] ?? []),
    );
  }
}
