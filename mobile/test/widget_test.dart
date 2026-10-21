import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_app/app/app.dart';

void main() {
  testWidgets('LazyApp renders Today dashboard', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LazyApp()));
    await tester.pumpAndSettle();
    expect(find.text('Today Dashboard'), findsOneWidget);
  });
}
