import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/game_state.dart';
import '../../models/history_entry.dart';
import 'game_state_repository.dart';

class FirestoreGameStateRepository implements GameStateRepository {
  FirestoreGameStateRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _historyCol(String uid) =>
      _userDoc(uid).collection('history');

  @override
  Stream<GameState?> watch(String uid) {
    return _userDoc(uid).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return null;
      return GameState.fromMap(data);
    });
  }

  @override
  Future<GameState?> load(String uid) async {
    final snap = await _userDoc(uid).get();
    final data = snap.data();
    if (data == null) return null;
    return GameState.fromMap(data);
  }

  @override
  Future<void> save(String uid, GameState state) {
    final data = state.copyWith(updatedAt: DateTime.now()).toMap();
    return _userDoc(uid).set(data, SetOptions(merge: true));
  }

  @override
  Future<void> appendHistory(String uid, HistoryEntry entry) {
    return _historyCol(uid).add(entry.toMap());
  }

  @override
  Future<void> delete(String uid) async {
    final history = await _historyCol(uid).get();
    for (final doc in history.docs) {
      await doc.reference.delete();
    }
    await _userDoc(uid).delete();
  }
}
