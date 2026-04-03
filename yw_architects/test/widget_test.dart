import 'package:flutter_test/flutter_test.dart';
import 'package:yw_architects/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const YWArchitectsApp());
    expect(find.byType(YWArchitectsApp), findsOneWidget);
  });
}
