import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazy_app/core/network/ai_api_client.dart';

void main() {
  late Dio dio;
  late AiApiClient client;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    client = AiApiClient(
      dio: dio,
      timezoneResolver: () async => 'Asia/Jakarta',
    );
  });

  test('parseBrainDump returns list of extracted tasks on 200', () async {
    dio.httpClientAdapter = _MockAdapter((options) {
      if (options.path == '/api/v1/ai/parse') {
        final data = options.data as Map<String, dynamic>;
        expect(data['text'], 'Beli susu besok sore');
        expect(data['timezone'], 'Asia/Jakarta');
        expect(data['nowMs'], isPositive);

        return ResponseBody.fromString(
          '{"items": [{"title": "Beli susu", "suggestedDate": "2025-10-21", "suggestedTime": "16:00", "priority": "medium", "reason": "Sore hari"}]}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }
      return ResponseBody.fromString('', 404);
    });

    final items = await client.parseBrainDump('Beli susu besok sore');

    expect(items, hasLength(1));
    expect(items.first.title, 'Beli susu');
    expect(items.first.suggestedDate, '2025-10-21');
    expect(items.first.suggestedTime, '16:00');
    expect(items.first.priority, 'medium');
  });

  test('parseBrainDump throws AiTimeoutException on timeout error', () async {
    dio.httpClientAdapter = _MockAdapter((options) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.receiveTimeout,
      );
    });

    expect(
      () => client.parseBrainDump('Teks apa saja'),
      throwsA(isA<AiTimeoutException>()),
    );
  });

  test('parseBrainDump throws AiNetworkException on connection error', () async {
    dio.httpClientAdapter = _MockAdapter((options) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    });

    expect(
      () => client.parseBrainDump('Teks apa saja'),
      throwsA(isA<AiNetworkException>()),
    );
  });

  test('parseBrainDump throws AiSchemaException on HTTP 422', () async {
    dio.httpClientAdapter = _MockAdapter((options) {
      return ResponseBody.fromString(
        '{"code": "ai_schema_invalid"}',
        422,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });

    expect(
      () => client.parseBrainDump('Teks apa saja'),
      throwsA(isA<AiSchemaException>()),
    );
  });

  test('parseBrainDump throws AiServerException on HTTP 502', () async {
    dio.httpClientAdapter = _MockAdapter((options) {
      return ResponseBody.fromString(
        '{"code": "provider_error"}',
        502,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });

    expect(
      () => client.parseBrainDump('Teks apa saja'),
      throwsA(isA<AiServerException>()),
    );
  });
}

class _MockAdapter implements HttpClientAdapter {
  _MockAdapter(this._handler);

  final ResponseBody Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}
