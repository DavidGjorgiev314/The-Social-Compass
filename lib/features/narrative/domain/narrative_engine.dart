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
    final newRel = _applyRel(state.relationships, choice.rel);
    final newMemories = choice.memory == null
        ? state.memories
        : [...state.memories, choice.memory!];
    return state.copyWith(
      stats: newStats,
      flags: newFlags,
      relationships: newRel,
      memories: newMemories,
      currentNodeId: choice.nextNodeId,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, int> _applyRel(Map<String, int> current, Map<String, int> deltas) {
    if (deltas.isEmpty) return current;
    final next = {...current};
    deltas.forEach((id, delta) {
      final base = next[id] ?? GameState.neutralRelationship;
      next[id] = (base + delta).clamp(0, 100);
    });
    return next;
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
