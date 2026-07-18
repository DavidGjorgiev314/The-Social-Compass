import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:digital_compass/core/providers/firebase_providers.dart';
import 'package:digital_compass/data/repositories/game_state_repository.dart';
import 'package:digital_compass/features/game/application/game_controller.dart';
import 'package:digital_compass/models/game_state.dart';
import 'package:digital_compass/models/history_entry.dart';
import 'package:digital_compass/models/profile_choices.dart';

class FakeGameStateRepository implements GameStateRepository {
  final Map<String, GameState> store = {};
  final Map<String, List<HistoryEntry>> history = {};

  @override
  Future<GameState?> load(String uid) async => store[uid];

  @override
  Stream<GameState?> watch(String uid) async* {
    yield store[uid];
  }

  @override
  Future<void> save(String uid, GameState state) async {
    store[uid] = state;
  }

  @override
  Future<void> appendHistory(String uid, HistoryEntry entry) async {
    history.putIfAbsent(uid, () => []).add(entry);
  }

  @override
  Future<void> delete(String uid) async {
    store.remove(uid);
    history.remove(uid);
  }
}

void main() {
  late FakeGameStateRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = FakeGameStateRepository();
    container = ProviderContainer(
      overrides: [
        currentUidProvider.overrideWithValue('u1'),
        gameStateRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
  });

  test('creates and persists an initial game state on first load', () async {
    final state = await container.read(gameControllerProvider.future);

    expect(state.profile.completed, false);
    expect(state.day, 0);
    expect(repo.store['u1'], isNotNull);
  });

  test('completeProfile persists choices, sets gating flags, and starts day 1',
      () async {
    await container.read(gameControllerProvider.future);

    await container.read(gameControllerProvider.notifier).completeProfile(
          const ProfileChoices(
            displayName: 'Nova',
            nameChoice: NameChoice.alias,
            photoChoice: PhotoChoice.avatar,
            visibility: ProfileVisibility.public,
          ),
        );

    final saved = repo.store['u1']!;
    expect(saved.profile.completed, true);
    expect(saved.day, 1);
    expect(saved.currentNodeId, kFirstStoryNodeId);
    expect(saved.flag(flagProfilePublic), true);
    expect(saved.flag(flagProfileRealPhoto), false);
    expect(saved.flag(flagProfileRealName), false);
  });

  test('resetGame wipes progress back to a fresh initial state', () async {
    await container.read(gameControllerProvider.future);
    final notifier = container.read(gameControllerProvider.notifier);

    await notifier.completeProfile(
      const ProfileChoices(
        displayName: 'Nova',
        visibility: ProfileVisibility.public,
      ),
    );
    await notifier.resetGame();

    final saved = repo.store['u1']!;
    expect(saved.profile.completed, false);
    expect(saved.day, 0);
    expect(saved.flag(flagProfilePublic), false);
    expect(container.read(gameControllerProvider).value!.profile.completed, false);
  });
}
