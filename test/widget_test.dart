import 'package:flutter_test/flutter_test.dart';
import 'package:equily_assistent/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
  });
}
