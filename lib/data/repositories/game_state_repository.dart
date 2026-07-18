import '../../models/game_state.dart';
import '../../models/history_entry.dart';

abstract interface class GameStateRepository {
  Stream<GameState?> watch(String uid);

  Future<GameState?> load(String uid);

  Future<void> save(String uid, GameState state);

  Future<void> appendHistory(String uid, HistoryEntry entry);

  Future<void> delete(String uid);
}
