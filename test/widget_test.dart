import 'package:flutter_test/flutter_test.dart';
import 'package:demo_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VisionGROApp());
    expect(find.text('VisionGRO'), findsWidgets);
  });
}
