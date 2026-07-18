import 'package:flutter_test/flutter_test.dart';

import 'package:digital_compass/features/narrative/domain/ending.dart';
import 'package:digital_compass/features/narrative/domain/narrative_engine.dart';
import 'package:digital_compass/features/narrative/domain/story_models.dart';
import 'package:digital_compass/models/game_state.dart';
import 'package:digital_compass/models/game_stats.dart';

void main() {
  const engine = NarrativeEngine();

  final bullyNode = StoryNode(
    id: 'D1_BULLY_1',
    day: 1,
    lines: const [
      StoryLine(senderId: 'devon', senderName: 'Devon', text: 'lol who told her she could draw'),
    ],
    choices: const [
      StoryChoice(
        id: 'join',
        text: 'lmaooo fr',
        nextNodeId: 'D2_CLIQUE',
        delta: StatDelta(friendship: 15, trust: -15),
        setFlags: {StoryFlags.joinedClique: true},
      ),
      StoryChoice(
        id: 'defend',
        text: 'not cool, her art is good',
        nextNodeId: 'D2_ALLY',
        delta: StatDelta(trust: 15, friendship: -10),
        setFlags: {StoryFlags.defendedNadia: true},
      ),
    ],
  );

  group('NarrativeEngine', () {
    test('applying a choice updates stats, flags, and current node', () {
      final state = GameState.initial();
      final defend = bullyNode.choices[1];

      final next = engine.applyChoice(state, defend);

      expect(next.currentNodeId, 'D2_ALLY');
      expect(next.stats.trust, 65);
      expect(next.stats.friendship, 10);
      expect(next.flag(StoryFlags.defendedNadia), true);
    });

    test('awareness-gated choices only show when the threshold is met', () {
      final node = StoryNode(
        id: 'D3_PHISH',
        day: 3,
        kind: NodeKind.phishing,
        choices: const [
          StoryChoice(id: 'click', text: 'open link', nextNodeId: 'x'),
          StoryChoice(
            id: 'catch',
            text: "wait, that's not her real handle",
            nextNodeId: 'y',
            visibleIf: StoryCondition(minAwareness: 60),
          ),
        ],
      );

      final low = GameState.initial();
      final high = low.copyWith(
        stats: low.stats.copyWith(awareness: 65),
      );

      expect(engine.visibleChoices(node, low).length, 1);
      expect(engine.visibleChoices(node, high).length, 2);
    });
  });

  group('ending resolution', () {
    test('account compromise overrides everything else', () {
      final state = GameState.initial().copyWith(
        stats: const GameStats(friendship: 80, trust: 80, awareness: 80),
        flags: {
          StoryFlags.accountCompromised: true,
          StoryFlags.defendedNadia: true,
        },
      );
      expect(resolveEnding(state).id, 'compromised');
    });

    test('best ending requires trust, awareness, defending, and no bad phish', () {
      final state = GameState.initial().copyWith(
        stats: const GameStats(friendship: 80, trust: 80, awareness: 80),
        flags: {
          StoryFlags.defendedNadia: true,
          StoryFlags.phishedBadly: false,
        },
      );
      expect(resolveEnding(state).id, 'the_digital_compass');
    });

    test('falls back to the bystander when nothing matches strongly', () {
      final state = GameState.initial().copyWith(
        stats: const GameStats(friendship: 45, trust: 45, awareness: 45),
      );
      expect(resolveEnding(state).id, 'the_bystander');
    });
  });
}
