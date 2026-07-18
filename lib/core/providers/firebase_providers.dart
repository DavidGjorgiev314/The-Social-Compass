import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/firestore_game_state_repository.dart';
import '../../data/repositories/game_state_repository.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final gameStateRepositoryProvider = Provider<GameStateRepository>((ref) {
  return FirestoreGameStateRepository(ref.watch(firestoreProvider));
});
