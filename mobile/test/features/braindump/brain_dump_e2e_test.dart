import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_app/core/database/app_database.dart';
import 'package:lazy_app/core/network/ai_api_client.dart';
import 'package:lazy_app/features/braindump/screens/brain_dump_screen.dart';
import 'package:lazy_app/features/tasks/providers/task_providers.dart';
import 'package:mocktail/mocktail.dart';

class MockAiApiClient extends Mock implements AiApiClient {}

void main() {
  late AppDatabase db;
  late MockAiApiClient mockAiClient;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    mockAiClient = MockAiApiClient();
  });

  Future<void> pumpBrainDump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          aiApiClientProvider.overrideWithValue(mockAiClient),
        ],
        child: const MaterialApp(home: BrainDumpScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('successful extraction navigates to preview screen',
      (tester) async {
    when(() => mockAiClient.parseBrainDump(any())).thenAnswer(
      (_) async => [
        const ExtractedTask(
          title: 'Meeting dengan tim',
          suggestedDate: '2025-10-22',
          suggestedTime: '10:00',
        ),
      ],
    );

    await pumpBrainDump(tester);

    await tester.enterText(
      find.byKey(const Key('braindump-textarea')),
      'Besok jam 10 pagi meeting dengan tim',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('extract-ai-btn')));
    await tester.pumpAndSettle();

    // Verifikasi navigasi ke BrainDumpPreviewScreen
    expect(find.text('Tinjau Hasil AI'), findsOneWidget);
    expect(find.text('Meeting dengan tim'), findsOneWidget);
    expect(find.text('2025-10-22'), findsOneWidget);

    await db.close();
  });

  testWidgets('offline failure offers fallback dialog to save to Thought Inbox',
      (tester) async {
    when(() => mockAiClient.parseBrainDump(any())).thenThrow(
      const AiNetworkException('Koneksi internet padam'),
    );

    await pumpBrainDump(tester);

    const dumpText = 'Catatan ide penting saat sedang offline di jalan';
    await tester.enterText(
      find.byKey(const Key('braindump-textarea')),
      dumpText,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('extract-ai-btn')));
    await tester.pumpAndSettle();

    // Verifikasi dialog fallback tampil
    expect(find.text('Koneksi AI Sedang Terkendala'), findsOneWidget);
    expect(find.textContaining('Koneksi internet padam'), findsOneWidget);
    expect(find.byKey(const Key('fallback-save-inbox-btn')), findsOneWidget);

    // Tekan simpan ke Inbox
    await tester.tap(find.byKey(const Key('fallback-save-inbox-btn')));
    await tester.pumpAndSettle();

    // Verifikasi catatan tersimpan ke SQLite ThoughtInbox
    final thoughts = await db.select(db.thoughtInbox).get();
    expect(thoughts, hasLength(1));
    expect(thoughts.first.content, dumpText);
    expect(thoughts.first.converted, isFalse);

    await db.close();
  });
}
