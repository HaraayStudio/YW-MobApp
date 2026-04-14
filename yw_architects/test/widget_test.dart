import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yw_architects/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const YWArchitectsApp());
    
    // Wait for initialization and splash screen to settle
    // The splash screen lasts about 2 seconds
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.byType(YWArchitectsApp), findsOneWidget);
  });
}
