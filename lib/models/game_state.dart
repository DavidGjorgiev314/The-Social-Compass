import 'game_stats.dart';
import 'photo_request.dart';
import 'profile_choices.dart';
import 'stored_message.dart';

class GameState {
  const GameState({
    required this.profile,
    required this.day,
    required this.currentNodeId,
    required this.stats,
    required this.flags,
    required this.endingsUnlocked,
    required this.currentEnding,
    required this.createdAt,
    required this.updatedAt,
    this.threads = const {},
    this.unread = const {},
    this.relationships = const {},
    this.memories = const [],
    this.pendingPhoto,
    this.schemaVersion = currentSchemaVersion,
  });

  static const int currentSchemaVersion = 2;

  /// Neutral starting point for a relationship the story hasn't touched yet.
  static const int neutralRelationship = 50;

  final ProfileChoices profile;
  final int day;
  final String currentNodeId;
  final GameStats stats;
  final Map<String, bool> flags;
  final List<String> endingsUnlocked;
  final String? currentEnding;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, List<StoredMessage>> threads;
  final Map<String, bool> unread;

  /// Per-character relationship score (0..100). Drives the branching so a
  /// choice with one person ripples out into how everyone else treats you.
  final Map<String, int> relationships;

  /// Ordered log of the "will remember that" beats the player has triggered.
  final List<String> memories;

  /// A photo an NPC is currently waiting on, if any.
  final PhotoRequest? pendingPhoto;

  final int schemaVersion;

  bool flag(String key) => flags[key] ?? false;

  List<StoredMessage> thread(String conversationId) =>
      threads[conversationId] ?? const [];

  bool isUnread(String conversationId) => unread[conversationId] ?? false;

  int relationship(String characterId) =>
      relationships[characterId] ?? neutralRelationship;

  factory GameState.initial({DateTime? now}) {
    final timestamp = now ?? DateTime.now();
    return GameState(
      profile: const ProfileChoices(),
      day: 0,
      currentNodeId: 'D0_START',
      stats: const GameStats(),
      flags: const {},
      endingsUnlocked: const [],
      currentEnding: null,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  GameState copyWith({
    ProfileChoices? profile,
    int? day,
    String? currentNodeId,
    GameStats? stats,
    Map<String, bool>? flags,
    List<String>? endingsUnlocked,
    Object? currentEnding = _sentinel,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, List<StoredMessage>>? threads,
    Map<String, bool>? unread,
    Map<String, int>? relationships,
    List<String>? memories,
    Object? pendingPhoto = _sentinel,
    int? schemaVersion,
  }) {
    return GameState(
      profile: profile ?? this.profile,
      day: day ?? this.day,
      currentNodeId: currentNodeId ?? this.currentNodeId,
      stats: stats ?? this.stats,
      flags: flags ?? this.flags,
      endingsUnlocked: endingsUnlocked ?? this.endingsUnlocked,
      currentEnding: currentEnding == _sentinel
          ? this.currentEnding
          : currentEnding as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      threads: threads ?? this.threads,
      unread: unread ?? this.unread,
      relationships: relationships ?? this.relationships,
      memories: memories ?? this.memories,
      pendingPhoto: pendingPhoto == _sentinel
          ? this.pendingPhoto
          : pendingPhoto as PhotoRequest?,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  GameState withFlag(String key, bool value) =>
      copyWith(flags: {...flags, key: value});

  Map<String, dynamic> toMap() => {
        'profile': profile.toMap(),
        'position': {
          'day': day,
          'currentNodeId': currentNodeId,
        },
        'stats': stats.toMap(),
        'flags': flags,
        'endings': {
          'unlocked': endingsUnlocked,
          'currentRun': currentEnding,
        },
        'threads': {
          for (final entry in threads.entries)
            entry.key: [for (final m in entry.value) m.toMap()],
        },
        'unread': unread,
        'relationships': relationships,
        'memories': memories,
        if (pendingPhoto != null) 'pendingPhoto': pendingPhoto!.toMap(),
        'meta': {
          'createdAt': createdAt.toIso8601String(),
          'updatedAt': updatedAt.toIso8601String(),
          'schemaVersion': schemaVersion,
        },
      };

  factory GameState.fromMap(Map<String, dynamic> map) {
    final position = (map['position'] as Map?)?.cast<String, dynamic>() ?? {};
    final endings = (map['endings'] as Map?)?.cast<String, dynamic>() ?? {};
    final meta = (map['meta'] as Map?)?.cast<String, dynamic>() ?? {};
    final rawFlags = (map['flags'] as Map?)?.cast<String, dynamic>() ?? {};
    final rawThreads = (map['threads'] as Map?)?.cast<String, dynamic>() ?? {};
    final rawUnread = (map['unread'] as Map?)?.cast<String, dynamic>() ?? {};
    final rawRel = (map['relationships'] as Map?)?.cast<String, dynamic>() ?? {};
    final rawPhoto = (map['pendingPhoto'] as Map?)?.cast<String, dynamic>();

    return GameState(
      profile: ProfileChoices.fromMap(
        (map['profile'] as Map?)?.cast<String, dynamic>(),
      ),
      day: (position['day'] as num?)?.toInt() ?? 0,
      currentNodeId: position['currentNodeId'] as String? ?? 'D0_START',
      stats: GameStats.fromMap((map['stats'] as Map?)?.cast<String, dynamic>()),
      flags: rawFlags.map((k, v) => MapEntry(k, v as bool? ?? false)),
      endingsUnlocked:
          (endings['unlocked'] as List?)?.cast<String>() ?? const [],
      currentEnding: endings['currentRun'] as String?,
      threads: {
        for (final entry in rawThreads.entries)
          entry.key: [
            for (final m in (entry.value as List? ?? const []))
              StoredMessage.fromMap((m as Map).cast<String, dynamic>()),
          ],
      },
      unread: rawUnread.map((k, v) => MapEntry(k, v as bool? ?? false)),
      relationships:
          rawRel.map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 50)),
      memories: (map['memories'] as List?)?.cast<String>() ?? const [],
      pendingPhoto: rawPhoto == null ? null : PhotoRequest.fromMap(rawPhoto),
      createdAt:
          DateTime.tryParse(meta['createdAt'] as String? ?? '') ??
              DateTime.now(),
      updatedAt:
          DateTime.tryParse(meta['updatedAt'] as String? ?? '') ??
              DateTime.now(),
      schemaVersion: (meta['schemaVersion'] as num?)?.toInt() ?? 1,
    );
  }

  static const Object _sentinel = Object();
}
