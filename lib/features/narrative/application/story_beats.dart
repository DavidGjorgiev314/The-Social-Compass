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
  'impostor': 'maya_chenn',
  'burnbook': '🔥 side chat',
};

String channelName(String? conversationId) =>
    kChannelNames[conversationId] ?? 'Pixelgram';

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
          for (final c in visibleChoices) ReplyOption(id: c.id, text: c.text),
        ],
      ),
  ];
}
