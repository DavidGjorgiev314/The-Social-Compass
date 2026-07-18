import 'package:flutter_test/flutter_test.dart';

import 'package:digital_compass/models/game_state.dart';
import 'package:digital_compass/models/game_stats.dart';
import 'package:digital_compass/models/profile_choices.dart';

void main() {
  group('GameStats', () {
    test('adjust clamps to 0..100', () {
      const stats = GameStats(friendship: 95, trust: 5, awareness: 50);
      final raised = stats.adjust(friendship: 20);
      final lowered = stats.adjust(trust: -20);

      expect(raised.friendship, 100);
      expect(lowered.trust, 0);
      expect(raised.awareness, 50);
    });
  });

  group('GameState mapping', () {
    test('round-trips through toMap/fromMap', () {
      final now = DateTime.parse('2026-07-18T10:00:00.000');
      final original = GameState.initial(now: now).copyWith(
        profile: const ProfileChoices(
          displayName: 'Nova',
          nameChoice: NameChoice.alias,
          photoChoice: PhotoChoice.avatar,
          visibility: ProfileVisibility.public,
          completed: true,
        ),
        day: 3,
        currentNodeId: 'D3_BULLY_2',
        stats: const GameStats(friendship: 40, trust: 65, awareness: 70),
        flags: {'ally': true, 'reported_devon': true},
        endingsUnlocked: ['the_digital_compass'],
        currentEnding: null,
      );

      final restored = GameState.fromMap(original.toMap());

      expect(restored.profile.displayName, 'Nova');
      expect(restored.profile.isPublic, true);
      expect(restored.day, 3);
      expect(restored.currentNodeId, 'D3_BULLY_2');
      expect(restored.stats.trust, 65);
      expect(restored.flag('ally'), true);
      expect(restored.flag('reported_devon'), true);
      expect(restored.flag('unknown'), false);
      expect(restored.endingsUnlocked, ['the_digital_compass']);
      expect(restored.currentEnding, isNull);
    });

    test('fromMap tolerates missing sections', () {
      final restored = GameState.fromMap(const {});
      expect(restored.day, 0);
      expect(restored.stats.friendship, 20);
      expect(restored.profile.completed, false);
    });
  });
}
