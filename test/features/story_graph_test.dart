import 'package:flutter_test/flutter_test.dart';

import 'package:digital_compass/features/narrative/data/story_graph.dart';
import 'package:digital_compass/features/narrative/domain/ending.dart';
import 'package:digital_compass/features/narrative/domain/narrative_engine.dart';
import 'package:digital_compass/features/narrative/domain/story_models.dart';
import 'package:digital_compass/models/game_state.dart';

void main() {
  const engine = NarrativeEngine();

  StoryChoice choiceById(String nodeId, String choiceId) =>
      storyNode(nodeId)!.choices.firstWhere((c) => c.id == choiceId);

  test('every choice and auto-link points to a real node', () {
    for (final node in kStoryGraph.values) {
      for (final choice in node.choices) {
        expect(
          kStoryGraph.containsKey(choice.nextNodeId),
          isTrue,
          reason: '${node.id} -> ${choice.id} points to missing ${choice.nextNodeId}',
        );
      }
      if (node.autoNextNodeId != null) {
        expect(
          kStoryGraph.containsKey(node.autoNextNodeId),
          isTrue,
          reason: '${node.id} auto-links to missing ${node.autoNextNodeId}',
        );
      }
      for (final route in node.routes) {
        expect(
          kStoryGraph.containsKey(route.nodeId),
          isTrue,
          reason: '${node.id} routes to missing ${route.nodeId}',
        );
      }
    }
  });

  test('an ending node is reachable and terminal', () {
    final ending = kStoryGraph['D_ENDING'];
    expect(ending, isNotNull);
    expect(ending!.kind, NodeKind.ending);
  });

  test('the "defend then report" path builds trust and awareness', () {
    var state = GameState.initial().copyWith(currentNodeId: 'D1_START', day: 1);

    state = engine.applyChoice(state, choiceById('D1_START', 'warm'));
    expect(state.currentNodeId, 'D1_BULLY_1');

    state = engine.applyChoice(state, choiceById('D1_BULLY_1', 'defend'));
    expect(state.flag(StoryFlags.defendedNadia), true);
    expect(state.currentNodeId, 'D1_PHISH_1');

    state = engine.applyChoice(state, choiceById('D1_PHISH_1', 'report'));
    expect(state.currentNodeId, 'D1_END');

    expect(state.stats.trust, greaterThan(50));
    expect(state.stats.awareness, greaterThan(35));
    expect(state.flag(StoryFlags.joinedClique), false);
  });

  GameState walk(Map<String, String> picks) {
    var state = GameState.initial().copyWith(currentNodeId: 'D1_START', day: 1);
    var id = 'D1_START';
    var guard = 0;
    while (guard++ < 200) {
      final node = storyNode(id)!;
      switch (node.kind) {
        case NodeKind.ending:
          return state;
        case NodeKind.router:
          id = node.resolveRoute((c) => c.matches(state))!;
        case NodeKind.event:
        case NodeKind.dayBreak:
          id = node.autoNextNodeId!;
        case NodeKind.chat:
        case NodeKind.phishing:
          final choice =
              node.choices.firstWhere((c) => c.id == picks[node.id]);
          state = engine.applyChoice(state, choice);
          id = state.currentNodeId;
      }
    }
    throw StateError('walk did not terminate (loop in graph?)');
  }

  test('a defend-and-report private-profile run reaches the best ending', () {
    final state = walk({
      'D1_START': 'warm',
      'D1_BULLY_1': 'defend',
      'D1_PHISH_1': 'report',
      'D2_ALLY': 'befriend',
      'D3_BULLY_2': 'defend',
      'D3_PHISH_3': 'report',
      'D4_NADIA_SCARED': 'help',
      'D4_PHISH_4': 'report',
      'D5_TURN': 'support',
      'D5_PHISH_5': 'report',
      'D6_START': 'reflect',
    });

    expect(state.flag(StoryFlags.defendedNadia), true);
    expect(state.flag(StoryFlags.phishedBadly), false);
    expect(resolveEnding(state).id, 'the_digital_compass');
  });

  test('a join-the-clique run reaches the popular-but-hollow ending', () {
    final state = walk({
      'D1_START': 'warm',
      'D1_BULLY_1': 'join',
      'D1_PHISH_1': 'delete',
      'D2_CLIQUE': 'lean_in',
      'D3_BULLY_2': 'join',
      'D3_PHISH_3': 'delete',
      'D4_BURNBOOK': 'feed',
      'D4_PHISH_4': 'delete',
      'D5_TURN': 'later',
      'D5_PHISH_5': 'delete',
      'D6_START': 'reflect',
    });

    expect(state.flag(StoryFlags.joinedClique), true);
    expect(resolveEnding(state).id, 'popular_but_hollow');
  });

  test('clicking the account-recovery scam forces the compromised ending', () {
    final state = walk({
      'D1_START': 'warm',
      'D1_BULLY_1': 'defend',
      'D1_PHISH_1': 'report',
      'D2_ALLY': 'befriend',
      'D3_BULLY_2': 'defend',
      'D3_PHISH_3': 'report',
      'D4_NADIA_SCARED': 'help',
      'D4_PHISH_4': 'click',
    });

    expect(state.flag(StoryFlags.accountCompromised), true);
    expect(resolveEnding(state).id, 'compromised');
  });

  test('clicking the scam link routes to the lockout and drops awareness', () {
    var state = GameState.initial().copyWith(currentNodeId: 'D1_PHISH_1', day: 1);

    state = engine.applyChoice(state, choiceById('D1_PHISH_1', 'click'));

    expect(state.currentNodeId, 'D1_LOCKOUT');
    expect(state.flag('phish_hit_1'), true);
    expect(state.stats.awareness, lessThan(35));
  });
}
