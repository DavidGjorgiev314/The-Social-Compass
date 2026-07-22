class ChatParticipant {
  const ChatParticipant({
    required this.id,
    required this.name,
    required this.isPlayer,
  });

  final String id;
  final String name;
  final bool isPlayer;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.fromPlayer,
    this.system = false,
    this.memory = false,
    this.imageAsset,
  });

  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final bool fromPlayer;
  final bool system;

  /// A "will remember that" beat.
  final bool memory;

  /// When set the bubble renders an image (photo) instead of text.
  final String? imageAsset;
}

class ReplyOption {
  const ReplyOption({required this.id, required this.text, this.isAction = false});

  final String id;
  final String text;
  final bool isAction;
}

sealed class ChatBeat {
  const ChatBeat();
}

class NpcLine extends ChatBeat {
  const NpcLine({
    required this.senderId,
    required this.senderName,
    required this.text,
  });

  final String senderId;
  final String senderName;
  final String text;
}

class PlayerChoice extends ChatBeat {
  const PlayerChoice({required this.options});

  final List<ReplyOption> options;
}

class SystemLine extends ChatBeat {
  const SystemLine({required this.text});

  final String text;
}

/// A "will remember that" beat, styled distinctly from system lines.
class MemoryLine extends ChatBeat {
  const MemoryLine({required this.text});

  final String text;
}
