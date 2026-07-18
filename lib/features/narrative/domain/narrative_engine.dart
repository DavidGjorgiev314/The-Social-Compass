import '../../../models/game_state.dart';
import 'story_models.dart';

class NarrativeEngine {
  const NarrativeEngine();

  List<StoryChoice> visibleChoices(StoryNode node, GameState state) {
    return node.choices
        .where((c) => c.visibleIf == null || c.visibleIf!.matches(state))
        .toList();
  }

  GameState applyChoice(GameState state, StoryChoice choice) {
    final newStats = choice.delta.applyTo(state.stats);
    final newFlags = {...state.flags, ...choice.setFlags};
    return state.copyWith(
      stats: newStats,
      flags: newFlags,
      currentNodeId: choice.nextNodeId,
      updatedAt: DateTime.now(),
    );
  }

  GameState advanceTo(GameState state, String nodeId) {
    return state.copyWith(currentNodeId: nodeId, updatedAt: DateTime.now());
  }

  GameState enterDay(GameState state, int day, String firstNodeId) {
    return state.copyWith(
      day: day,
      currentNodeId: firstNodeId,
      updatedAt: DateTime.now(),
    );
  }
}
