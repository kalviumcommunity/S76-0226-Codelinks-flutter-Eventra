import 'package:flutter_test/flutter_test.dart';
import 'package:eventra/main.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EventraApp());

    // Verify that Splash Screen is shown.
    expect(find.text('Eventra'), findsOneWidget);
  });
}
