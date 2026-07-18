class GameStats {
  const GameStats({
    this.friendship = 20,
    this.trust = 50,
    this.awareness = 35,
  });

  final int friendship;
  final int trust;
  final int awareness;

  static int _clamp(int v) => v.clamp(0, 100);

  GameStats adjust({int friendship = 0, int trust = 0, int awareness = 0}) {
    return GameStats(
      friendship: _clamp(this.friendship + friendship),
      trust: _clamp(this.trust + trust),
      awareness: _clamp(this.awareness + awareness),
    );
  }

  GameStats copyWith({int? friendship, int? trust, int? awareness}) {
    return GameStats(
      friendship: _clamp(friendship ?? this.friendship),
      trust: _clamp(trust ?? this.trust),
      awareness: _clamp(awareness ?? this.awareness),
    );
  }

  Map<String, dynamic> toMap() => {
        'friendship': friendship,
        'trust': trust,
        'awareness': awareness,
      };

  factory GameStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const GameStats();
    return GameStats(
      friendship: (map['friendship'] as num?)?.toInt() ?? 20,
      trust: (map['trust'] as num?)?.toInt() ?? 50,
      awareness: (map['awareness'] as num?)?.toInt() ?? 35,
    );
  }
}
