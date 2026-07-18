import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  try {
    await Firebase.initializeApp();
  } catch (error, stack) {
    debugPrintStack(label: 'Firebase init failed: $error', stackTrace: stack);
  }
  runApp(const ProviderScope(child: DigitalCompassApp()));
}
