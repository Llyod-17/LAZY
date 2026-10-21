import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_app/core/theme/app_colors.dart';
import 'package:lazy_app/core/widgets/app_button.dart';
import 'package:lazy_app/core/widgets/app_card.dart';
import 'package:lazy_app/core/widgets/status_badge.dart';

void main() {
  group('AppButton', () {
    Future<void> pumpButton(WidgetTester tester, Widget button) {
      return tester.pumpWidget(MaterialApp(home: Scaffold(body: button)));
    }

    testWidgets('primary: min touch target 48x48', (tester) async {
      await pumpButton(tester, const AppButton(label: 'Simpan', onTap: _noop));
      final size = tester.getSize(find.byType(FilledButton));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(size.width, greaterThanOrEqualTo(48));
    });

    testWidgets('primary: uses butter yellow', (tester) async {
      await pumpButton(tester, const AppButton(label: 'Simpan', onTap: _noop));
      final filled = tester.widget<FilledButton>(find.byType(FilledButton));
      final bg = filled.style?.backgroundColor?.resolve(const {});
      expect(bg, AppColors.primary);
    });

    testWidgets('disabled when onTap null', (tester) async {
      await pumpButton(tester, const AppButton(label: 'Simpan'));
      final filled = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(filled.onPressed, isNull);
    });

    testWidgets('secondary: outlined variant', (tester) async {
      await pumpButton(
        tester,
        const AppButton(label: 'Batal', onTap: _noop, variant: AppButtonVariant.secondary),
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('invokes onTap', (tester) async {
      var tapped = false;
      await pumpButton(
        tester,
        AppButton(label: 'OK', onTap: () => tapped = true),
      );
      await tester.tap(find.byType(AppButton));
      expect(tapped, isTrue);
    });
  });

  group('AppCard', () {
    testWidgets('renders surface color with border', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppCard(child: Text('isi')))),
      );
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.decoration, isA<BoxDecoration>());
      final deco = container.decoration as BoxDecoration;
      expect(deco.color, AppColors.surface);
      expect(deco.border?.top.color, AppColors.border);
      expect(deco.border?.top.width, 1);
    });

    testWidgets('taps when onTap provided', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(onTap: () => tapped = true, child: const Text('isi')),
          ),
        ),
      );
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });
  });

  group('StatusBadge', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: StatusBadge(label: 'Proses'))),
      );
      expect(find.text('Proses'), findsOneWidget);
    });
  });
}

void _noop() {}
