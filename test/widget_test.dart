// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:korean_history_bite/app.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: KoreanHistoryApp(),
      ),
    );

    // Verify the app loads (placeholder is shown for now)
    expect(find.byType(KoreanHistoryApp), findsOneWidget);
  });
}
