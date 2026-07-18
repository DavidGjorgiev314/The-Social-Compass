import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/config/firebase_config.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository(this._auth);

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _googleSignIn.initialize(serverClientId: FirebaseConfig.serverClientId);
    _initialized = true;
  }

  Future<UserCredential> signInWithGoogle() async {
    if (!FirebaseConfig.isConfigured) {
      throw const AuthException(
        'Sign-in is not configured yet. Add your Web client ID first.',
      );
    }

    await _ensureInitialized();

    if (!_googleSignIn.supportsAuthenticate()) {
      throw const AuthException(
        'Google sign-in is not supported on this platform.',
      );
    }

    try {
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const AuthException('Could not obtain Google credentials.');
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      return await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthException('Sign-in cancelled.');
      }
      throw AuthException('Google sign-in failed: ${e.code.name}.');
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Authentication failed.');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
