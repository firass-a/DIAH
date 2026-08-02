import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:diah/main.dart';

void main() {
  testWidgets('Diah app boots', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DiahApp()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Diah'), findsOneWidget);
  });
}
