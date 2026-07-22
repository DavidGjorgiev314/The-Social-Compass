class StoredMessage {
  const StoredMessage({
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.fromPlayer,
    required this.nodeId,
    this.system = false,
    this.memory = false,
    this.imageAsset,
  });

  final String text;
  final String senderId;
  final String senderName;
  final bool fromPlayer;
  final String nodeId;
  final bool system;

  /// A "will remember that" beat, rendered as a distinct centered pill.
  final bool memory;

  /// When set the message is an image (photo) rather than plain text.
  final String? imageAsset;

  Map<String, dynamic> toMap() => {
        'text': text,
        'senderId': senderId,
        'senderName': senderName,
        'fromPlayer': fromPlayer,
        'nodeId': nodeId,
        'system': system,
        'memory': memory,
        if (imageAsset != null) 'imageAsset': imageAsset,
      };

  factory StoredMessage.fromMap(Map<String, dynamic> map) {
    return StoredMessage(
      text: map['text'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? '',
      fromPlayer: map['fromPlayer'] as bool? ?? false,
      nodeId: map['nodeId'] as String? ?? '',
      system: map['system'] as bool? ?? false,
      memory: map['memory'] as bool? ?? false,
      imageAsset: map['imageAsset'] as String?,
    );
  }
}
