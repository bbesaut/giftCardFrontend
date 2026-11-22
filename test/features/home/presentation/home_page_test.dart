import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gift_card_front/features/home/presentation/home_page.dart';

void main() {
  // HomePage is no longer the app's entry point (that's LoginPage now, see
  // app.dart) - it's reached after a successful login, so it's tested in
  // isolation rather than through GiftCardApp.
  testWidgets('should_displayTitle_when_rendered', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text(HomePage.title), findsOneWidget);
  });
}
