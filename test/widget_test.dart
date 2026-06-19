import 'package:flutter_test/flutter_test.dart';
import 'package:horsepower_tracker_mobile/services/database_service.dart';
import 'package:horsepower_tracker_mobile/main.dart';

void main() {
  testWidgets('アプリが起動する', (WidgetTester tester) async {
    final dbService = DatabaseService();
    await dbService.initialize();
    await tester.pumpWidget(HorsepowerTrackerApp(dbService: dbService));
    expect(find.byType(HorsepowerTrackerApp), findsOneWidget);
  });
}
