import 'messaggio.dart';

class Chat {
  final String id;
  final String subject;
  final Messaggio lastMessage;
  final List<String> participantsNames;

  Chat({
    required this.id,
    required this.subject,
    required this.lastMessage,
    required this.participantsNames,
  });

  factory Chat.fromMap(String id, Map<dynamic, dynamic> data) {
    return Chat(
      id: id,
      subject: data['subject'] ?? '',
      lastMessage: Messaggio.fromMap(data['lastMessage'] ?? {}),
      participantsNames: List<String>.from(data['participantsNames'] ?? []),
    );
  }
}
