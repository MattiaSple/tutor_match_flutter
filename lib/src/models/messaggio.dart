class Messaggio {
  final String senderId;
  final String text;
  final int timestamp;

  Messaggio({
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  // Factory method per creare un Messaggio da Firebase
  factory Messaggio.fromMap(Map<dynamic, dynamic> data) {
    return Messaggio(
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? 0,
    );
  }
}
