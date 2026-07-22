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
    this.minRel = const {},
    this.maxRel = const {},
  });

  final Map<String, bool> flags;
  final int? minFriendship;
  final int? minTrust;
  final int? minAwareness;
  final int? maxFriendship;
  final int? maxTrust;
  final int? maxAwareness;

  /// Per-character relationship gates (characterId -> threshold).
  final Map<String, int> minRel;
  final Map<String, int> maxRel;

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
    for (final entry in minRel.entries) {
      if (state.relationship(entry.key) < entry.value) return false;
    }
    for (final entry in maxRel.entries) {
      if (state.relationship(entry.key) > entry.value) return false;
    }
    return true;
  }
}

class StoryChoice {
  const StoryChoice({
    required this.id,
    required this.text,
    required this.nextNodeId,
    this.delta = const StatDelta(),
    this.rel = const {},
    this.setFlags = const {},
    this.visibleIf,
    this.isAction = false,
    this.memory,
    this.opensGallery = false,
  });

  final String id;
  final String text;
  final String nextNodeId;
  final StatDelta delta;

  /// Per-character relationship changes (characterId -> delta). This is what
  /// makes a single reply ripple across every storyline.
  final Map<String, int> rel;

  final Map<String, bool> setFlags;
  final StoryCondition? visibleIf;
  final bool isAction;

  /// When set, choosing this drops a memory beat into the chat (e.g.
  /// "Nadia will remember that.") and logs it to the save.
  final String? memory;

  /// When true, choosing this defers the story: it opens the Gallery so the
  /// player can pick a photo to send. Resolves to [nextNodeId] once sent.
  final bool opensGallery;
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

enum NodeKind { chat, phishing, photoRequest, event, dayBreak, ending, router }

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
