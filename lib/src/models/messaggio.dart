class Messaggio {
  final String senderId;
  final String text;
  final int timestamp;
  final List<String> unreadBy;

  Messaggio({
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.unreadBy,
  });

  factory Messaggio.fromMap(Map<dynamic, dynamic> data) {
    return Messaggio(
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? 0,
      unreadBy: List<String>.from(data['unreadBy'] ?? []),
    );
  }
}
