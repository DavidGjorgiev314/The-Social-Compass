import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:digital_compass/core/theme/app_theme.dart';
import 'package:digital_compass/features/phone_shell/presentation/phone_shell.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Widget harness() => ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const PhoneShell()),
      );

  testWidgets('boots to a lock screen with an unlock hint', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Swipe up to open'), findsOneWidget);
  });

  testWidgets('tapping the lock screen unlocks to the home screen',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.text('Swipe up to open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Swipe up to open'), findsNothing);
    expect(find.text('Settings'), findsWidgets);
  });
}
