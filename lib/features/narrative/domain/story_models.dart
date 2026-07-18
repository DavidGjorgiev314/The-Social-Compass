import '../../../models/game_state.dart';
import '../../../models/game_stats.dart';

class StatDelta {
  const StatDelta({this.friendship = 0, this.trust = 0, this.awareness = 0});

  final int friendship;
  final int trust;
  final int awareness;

  GameStats applyTo(GameStats stats) => stats.adjust(
        friendship: friendship,
        trust: trust,
        awareness: awareness,
      );
}

class StoryCondition {
  const StoryCondition({
    this.flags = const {},
    this.minFriendship,
    this.minTrust,
    this.minAwareness,
    this.maxFriendship,
    this.maxTrust,
    this.maxAwareness,
  });

  final Map<String, bool> flags;
  final int? minFriendship;
  final int? minTrust;
  final int? minAwareness;
  final int? maxFriendship;
  final int? maxTrust;
  final int? maxAwareness;

  bool matches(GameState state) {
    for (final entry in flags.entries) {
      if (state.flag(entry.key) != entry.value) return false;
    }
    final s = state.stats;
    if (minFriendship != null && s.friendship < minFriendship!) return false;
    if (minTrust != null && s.trust < minTrust!) return false;
    if (minAwareness != null && s.awareness < minAwareness!) return false;
    if (maxFriendship != null && s.friendship > maxFriendship!) return false;
    if (maxTrust != null && s.trust > maxTrust!) return false;
    if (maxAwareness != null && s.awareness > maxAwareness!) return false;
    return true;
  }
}

class StoryChoice {
  const StoryChoice({
    required this.id,
    required this.text,
    required this.nextNodeId,
    this.delta = const StatDelta(),
    this.setFlags = const {},
    this.visibleIf,
  });

  final String id;
  final String text;
  final String nextNodeId;
  final StatDelta delta;
  final Map<String, bool> setFlags;
  final StoryCondition? visibleIf;
}

class StoryLine {
  const StoryLine({
    required this.senderId,
    required this.senderName,
    required this.text,
  });

  final String senderId;
  final String senderName;
  final String text;
}

enum NodeKind { chat, phishing, event, dayBreak, ending, router }

class NodeRoute {
  const NodeRoute({required this.when, required this.nodeId});

  final StoryCondition when;
  final String nodeId;
}

class StoryNode {
  const StoryNode({
    required this.id,
    required this.day,
    this.kind = NodeKind.chat,
    this.conversationId,
    this.lines = const [],
    this.choices = const [],
    this.autoNextNodeId,
    this.lockoutSeconds,
    this.routes = const [],
  });

  final String id;
  final int day;
  final NodeKind kind;
  final String? conversationId;
  final List<StoryLine> lines;
  final List<StoryChoice> choices;
  final String? autoNextNodeId;
  final int? lockoutSeconds;
  final List<NodeRoute> routes;

  String? resolveRoute(bool Function(StoryCondition) matches) {
    for (final route in routes) {
      if (matches(route.when)) return route.nodeId;
    }
    return autoNextNodeId;
  }

  bool get isTerminal =>
      kind == NodeKind.ending ||
      (choices.isEmpty && autoNextNodeId == null);
}
