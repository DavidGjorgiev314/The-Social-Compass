class FirebaseConfig {
  FirebaseConfig._();

  // Paste your Firebase "Web client" OAuth client ID here (see setup guide step 4).
  static const String serverClientId = '463611521574-h687m1nf70cpegmbl2frbrnsmarhi4el.apps.googleusercontent.com';

  static bool get isConfigured =>
      !serverClientId.startsWith('PASTE_');
}
