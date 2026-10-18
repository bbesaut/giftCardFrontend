import 'package:flutter_test/flutter_test.dart';
import 'package:gift_card_front/app.dart';
import 'package:gift_card_front/features/home/presentation/home_page.dart';

void main() {
  testWidgets('should_displayTitle_when_appStarts', (tester) async {
    await tester.pumpWidget(const GiftCardApp());

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text(HomePage.title), findsOneWidget);
  });
}
