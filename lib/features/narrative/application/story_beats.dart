import 'package:flutter/material.dart';

import '../../chat/domain/chat_models.dart';
import '../domain/story_models.dart';

const Map<String, String> kChannelNames = {
  'maya': 'Maya',
  'econ_group': 'Econ 101 · Group Chat',
  'campus_rewards': 'Campus Rewards',
  'devon': 'Devon Brooks',
  'nadia': 'Nadia Rahman',
  'jordan': 'Jordan Reyes',
  'security': 'Pixelgram Security',
  'impostor': 'Mayaa',
  'burnbook': '🔥 side chat',
};

String channelName(String? conversationId) =>
    kChannelNames[conversationId] ?? 'Pixelgram';

({String? asset, Color color, String initial}) channelAvatar(String? id) {
  switch (id) {
    case 'maya':
      return (asset: 'assets/images/avatars/maya.jpg', color: const Color(0xFFFF6FA5), initial: 'M');
    case 'devon':
      return (asset: 'assets/images/avatars/devon.jpg', color: const Color(0xFF4C8DFF), initial: 'D');
    case 'nadia':
      return (asset: 'assets/images/avatars/nadia.jpg', color: const Color(0xFF43E0B8), initial: 'N');
    case 'jordan':
      return (asset: 'assets/images/avatars/jordan.jpg', color: const Color(0xFFB06CFF), initial: 'J');
    case 'econ_group':
      return (asset: null, color: const Color(0xFF6B7385), initial: '#');
    case 'campus_rewards':
      return (asset: 'assets/images/avatars/campus_rewards.jpg', color: const Color(0xFFFFC15E), initial: r'$');
    case 'security':
      return (asset: 'assets/images/avatars/pixelgram_security.jpg', color: const Color(0xFFFF5C6C), initial: '!');
    case 'impostor':
      return (asset: 'assets/images/avatars/maya.jpg', color: const Color(0xFFFF6FA5), initial: 'M');
    case 'burnbook':
      return (asset: null, color: const Color(0xFFFF5C6C), initial: '🔥');
    default:
      return (asset: null, color: const Color(0xFF4C8DFF), initial: '?');
  }
}

List<ChatBeat> beatsForNode(
  StoryNode node,
  List<StoryChoice> visibleChoices, {
  bool withChannelNote = false,
}) {
  return [
    if (withChannelNote) SystemLine(text: channelName(node.conversationId)),
    for (final line in node.lines)
      NpcLine(
        senderId: line.senderId,
        senderName: line.senderName,
        text: line.text,
      ),
    if (visibleChoices.isNotEmpty)
      PlayerChoice(
        options: [
          for (final c in visibleChoices)
            ReplyOption(
              id: c.id,
              text: c.text,
              isAction: c.isAction ||
                  node.kind == NodeKind.phishing ||
                  c.text.trim().startsWith('('),
            ),
        ],
      ),
  ];
}
