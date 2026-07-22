/// A pending request from an NPC asking the player to send them a photo.
///
/// When active, the player can leave the conversation, open the Gallery
/// (Photos) app and pick a photo to send — or ignore the request entirely and
/// come back to decline it. Sending resolves the story from [sendNodeId].
class PhotoRequest {
  const PhotoRequest({
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.prompt,
    required this.sendNodeId,
    this.riskyOnly = false,
  });

  /// Conversation the photo should be delivered into.
  final String conversationId;

  /// Character who asked for the photo (for banners / mood changes).
  final String senderId;
  final String senderName;

  /// Short line describing what they asked for (shown in the Gallery).
  final String prompt;

  /// Story node to resolve into once the photo has been sent.
  final String sendNodeId;

  /// When true this request is fishing for a private/personal photo (used to
  /// nudge awareness consequences).
  final bool riskyOnly;

  Map<String, dynamic> toMap() => {
        'conversationId': conversationId,
        'senderId': senderId,
        'senderName': senderName,
        'prompt': prompt,
        'sendNodeId': sendNodeId,
        'riskyOnly': riskyOnly,
      };

  factory PhotoRequest.fromMap(Map<String, dynamic> map) {
    return PhotoRequest(
      conversationId: map['conversationId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? '',
      prompt: map['prompt'] as String? ?? '',
      sendNodeId: map['sendNodeId'] as String? ?? '',
      riskyOnly: map['riskyOnly'] as bool? ?? false,
    );
  }
}
