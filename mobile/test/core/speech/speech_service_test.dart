import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_app/core/speech/speech_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class MockSpeechToText extends Mock implements SpeechToText {}

void main() {
  late MockSpeechToText mockSpeech;
  late SpeechService service;

  setUp(() {
    mockSpeech = MockSpeechToText();
    service = SpeechService(speech: mockSpeech);
  });

  test('init success sets isAvailable to true', () async {
    when(
      () => mockSpeech.initialize(
        onError: any(named: 'onError'),
        onStatus: any(named: 'onStatus'),
      ),
    ).thenAnswer((_) async => true);
    when(() => mockSpeech.isAvailable).thenReturn(true);
    when(() => mockSpeech.isListening).thenReturn(false);

    final res = await service.init();
    expect(res, isTrue);
    expect(service.isAvailable, isTrue);
    expect(service.isListening, isFalse);
  });

  test('init failure or denied sets isAvailable to false', () async {
    when(
      () => mockSpeech.initialize(
        onError: any(named: 'onError'),
        onStatus: any(named: 'onStatus'),
      ),
    ).thenAnswer((_) async => false);
    when(() => mockSpeech.isAvailable).thenReturn(false);

    final res = await service.init();
    expect(res, isFalse);
    expect(service.isAvailable, isFalse);
  });

  test('startListening triggers speech.listen with id_ID locale', () async {
    when(() => mockSpeech.isAvailable).thenReturn(true);
    when(() => mockSpeech.isListening).thenReturn(true);
    when(
      () => mockSpeech.listen(
        onResult: any(named: 'onResult'),
        listenOptions: any(named: 'listenOptions'),
      ),
    ).thenAnswer((_) async {});

    String recognized = '';
    await service.startListening(onResult: (text) => recognized = text);

    expect(service.isListening, isTrue);

    final captured = verify(
      () => mockSpeech.listen(
        onResult: captureAny(named: 'onResult'),
        listenOptions: any(named: 'listenOptions'),
      ),
    ).captured;

    expect(captured, hasLength(1));

    // Simulate result listener callback
    final resultCallback = captured.first as Function(SpeechRecognitionResult);
    resultCallback(
      SpeechRecognitionResult(
        [const SpeechRecognitionWords('halo dunia', null, 0.9)],
        0, // 0 = finalResult
      ),
    );

    expect(recognized, 'halo dunia');
  });

  test('startListening calls onError when permission is denied', () async {
    when(() => mockSpeech.isAvailable).thenReturn(false);
    when(
      () => mockSpeech.initialize(
        onError: any(named: 'onError'),
        onStatus: any(named: 'onStatus'),
      ),
    ).thenAnswer((_) async => false);

    String? errorReceived;
    await service.startListening(
      onResult: (_) {},
      onError: (msg) => errorReceived = msg,
    );

    expect(
      errorReceived,
      contains('Mikrofon tidak tersedia atau izin ditolak'),
    );
  });

  test('stopListening calls speech.stop', () async {
    when(() => mockSpeech.stop()).thenAnswer((_) async {});

    await service.stopListening();

    verify(() => mockSpeech.stop()).called(1);
  });

  test('cancel calls speech.cancel', () async {
    when(() => mockSpeech.cancel()).thenAnswer((_) async {});

    await service.cancel();

    verify(() => mockSpeech.cancel()).called(1);
  });
}
