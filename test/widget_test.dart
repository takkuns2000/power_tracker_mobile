import 'package:flutter_test/flutter_test.dart';
import 'package:horsepower_tracker_mobile/main.dart';

void main() {
  testWidgets('アプリが起動する', (WidgetTester tester) async {
    await tester.pumpWidget(const HorsepowerTrackerApp());
    expect(find.byType(HorsepowerTrackerApp), findsOneWidget);
  });
}
