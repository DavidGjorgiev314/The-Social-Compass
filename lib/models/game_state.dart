import 'game_stats.dart';
import 'profile_choices.dart';

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
    this.schemaVersion = currentSchemaVersion,
  });

  static const int currentSchemaVersion = 1;

  final ProfileChoices profile;
  final int day;
  final String currentNodeId;
  final GameStats stats;
  final Map<String, bool> flags;
  final List<String> endingsUnlocked;
  final String? currentEnding;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int schemaVersion;

  bool flag(String key) => flags[key] ?? false;

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
