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

  test('defending Nadia sets the flag and builds trust', () {
    var state = GameState.initial().copyWith(currentNodeId: 'D1_START', day: 1);

    state = engine.applyChoice(state, choiceById('D1_START', 'warm'));
    expect(state.currentNodeId, 'D1_MAYA_2');

    state = engine.applyChoice(state, choiceById('D1_MAYA_2', 'ask'));
    expect(state.currentNodeId, 'D1_GROUP_1');

    state = engine.applyChoice(state, choiceById('D1_GROUP_1', 'defend'));
    expect(state.flag(StoryFlags.defendedNadia), true);
    expect(state.currentNodeId, 'D1_KAI');
    expect(state.stats.trust, greaterThan(50));
    expect(state.relationship('nadia'), greaterThan(GameState.neutralRelationship));
  });

  // Deterministic walker. Picks are keyed by node id -> choice id. Gallery
  // (opensGallery) choices are treated as plain advances here.
  GameState walk(Map<String, String> picks) {
    var state = GameState.initial().copyWith(currentNodeId: 'D1_START', day: 1);
    var id = 'D1_START';
    var guard = 0;
    while (guard++ < 300) {
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
        case NodeKind.photoRequest:
          final choice = node.choices.firstWhere(
            (c) => c.id == picks[node.id],
            orElse: () => throw StateError('no pick for ${node.id}'),
          );
          state = engine.applyChoice(state, choice);
          id = state.currentNodeId;
      }
    }
    throw StateError('walk did not terminate (loop in graph?)');
  }

  test('a defend-report-support run reaches the best ending', () {
    final state = walk({
      'D1_START': 'warm',
      'D1_MAYA_2': 'ask',
      'D1_GROUP_1': 'defend',
      'D1_KAI': 'warm',
      'D1_PHISH_1': 'report',
      'D2_NADIA_THANKS': 'befriend',
      'D2_AVA': 'accept',
      'D2_LEO': 'friendly',
      'D2_PHISH_2': 'report',
      'D3_GROUP_2': 'defend',
      'D3_TYLER': 'turn',
      'D3_MAYA_SECRET': 'advise',
      'D3_IMPOSTOR': 'report',
      'D4_NADIA_SCARED': 'help',
      'D4_AVA_PHOTO': 'shy',
      'D4_SECURITY': 'report',
      'D5_KAI': 'reconnect',
      'D5_NADIA_WARM': 'support',
      'D5_PHISH_5': 'report',
      'D6_STAND': 'proud',
      'D6_TYLER_OUT': 'welcome',
      'D6_FINAL_MAYA': 'reflect',
    });

    expect(state.flag(StoryFlags.defendedNadia), true);
    expect(state.flag(StoryFlags.phishedBadly), false);
    expect(state.stats.trust, greaterThanOrEqualTo(70));
    expect(state.stats.awareness, greaterThanOrEqualTo(70));
    expect(resolveEnding(state).id, 'the_digital_compass');
  });

  test('a join-the-clique run reaches the popular-but-hollow ending', () {
    final state = walk({
      'D1_START': 'warm',
      'D1_MAYA_2': 'ok',
      'D1_GROUP_1': 'join',
      'D1_KAI': 'brag',
      'D1_PHISH_1': 'delete',
      'D2_CLIQUE': 'lean_in',
      'D2_AVA': 'decline',
      'D2_LEO': 'rude',
      'D2_PHISH_2': 'delete',
      'D3_GROUP_2': 'join',
      'D3_TYLER': 'egg',
      'D3_MAYA_SECRET': 'dismiss',
      'D3_IMPOSTOR': 'delete',
      'D4_BURNBOOK': 'feed',
      'D4_SECURITY': 'ignore',
      'D5_KAI': 'deflect',
      'D5_NADIA_COLD': 'defensive',
      'D5_PHISH_5': 'delete',
      'D6_CLIQUE_FALLOUT': 'cover',
      'D6_FINAL_MAYA': 'reflect',
    });

    expect(state.flag(StoryFlags.joinedClique), true);
    expect(state.stats.friendship, greaterThanOrEqualTo(70));
    expect(resolveEnding(state).id, 'popular_but_hollow');
  });

  test('clicking the account-recovery scam forces the compromised ending', () {
    final state = walk({
      'D1_START': 'warm',
      'D1_MAYA_2': 'ok',
      'D1_GROUP_1': 'defend',
      'D1_KAI': 'warm',
      'D1_PHISH_1': 'report',
      'D2_NADIA_THANKS': 'befriend',
      'D2_AVA': 'maybe',
      'D2_LEO': 'polite',
      'D2_PHISH_2': 'report',
      'D3_GROUP_2': 'defend',
      'D3_TYLER': 'neutral',
      'D3_MAYA_SECRET': 'advise',
      'D3_IMPOSTOR': 'report',
      'D4_NADIA_SCARED': 'help',
      'D4_SECURITY': 'click',
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
