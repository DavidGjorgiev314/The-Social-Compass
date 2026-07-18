import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:digital_compass/core/theme/app_theme.dart';
import 'package:digital_compass/features/chat/domain/chat_models.dart';
import 'package:digital_compass/features/chat/presentation/chat_screen.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final script = [
    const NpcLine(senderId: 'maya', senderName: 'Maya', text: 'hi there'),
    const PlayerChoice(
      options: [ReplyOption(id: 'a', text: 'Hello Maya')],
    ),
    const NpcLine(senderId: 'maya', senderName: 'Maya', text: 'nice'),
  ];

  testWidgets('runs an NPC line, shows options, types and sends a reply',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: ChatScreen(title: 'Maya', script: script),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('hi there'), findsOneWidget);
    expect(find.text('Hello Maya'), findsOneWidget);

    await tester.tap(find.text('Hello Maya'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('Hello Maya'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    expect(find.text('nice'), findsOneWidget);

    await tester.pumpAndSettle();
  });
}
