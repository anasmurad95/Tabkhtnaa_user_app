import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/app.dart';

void main() {
  testWidgets('App builds', (tester) async {
    await tester.pumpWidget(const TabkhtnaaApp());
    expect(find.text('Tabkhtnaa'), findsOneWidget);
  });
}
