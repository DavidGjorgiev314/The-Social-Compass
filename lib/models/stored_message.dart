class StoredMessage {
  const StoredMessage({
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.fromPlayer,
    required this.nodeId,
    this.system = false,
  });

  final String text;
  final String senderId;
  final String senderName;
  final bool fromPlayer;
  final String nodeId;
  final bool system;

  Map<String, dynamic> toMap() => {
        'text': text,
        'senderId': senderId,
        'senderName': senderName,
        'fromPlayer': fromPlayer,
        'nodeId': nodeId,
        'system': system,
      };

  factory StoredMessage.fromMap(Map<String, dynamic> map) {
    return StoredMessage(
      text: map['text'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? '',
      fromPlayer: map['fromPlayer'] as bool? ?? false,
      nodeId: map['nodeId'] as String? ?? '',
      system: map['system'] as bool? ?? false,
    );
  }
}
