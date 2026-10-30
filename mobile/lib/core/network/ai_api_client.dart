import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

/// Model DTO hasil ekstraksi tugas dari backend AI.
class ExtractedTask {
  const ExtractedTask({
    required this.title,
    this.suggestedDate,
    this.suggestedTime,
    this.priority,
    this.reason,
  });

  factory ExtractedTask.fromJson(Map<String, dynamic> json) {
    return ExtractedTask(
      title: json['title'] as String? ?? '',
      suggestedDate: json['suggestedDate'] as String?,
      suggestedTime: json['suggestedTime'] as String?,
      priority: json['priority'] as String?,
      reason: json['reason'] as String?,
    );
  }

  final String title;
  final String? suggestedDate; // YYYY-MM-DD
  final String? suggestedTime; // HH:MM
  final String? priority; // low, medium, high
  final String? reason;

  Map<String, dynamic> toJson() => {
    'title': title,
    'suggestedDate': suggestedDate,
    'suggestedTime': suggestedTime,
    'priority': priority,
    'reason': reason,
  };
}

/// Hierarki exception terstruktur untuk koneksi AI backend.
sealed class AiApiException implements Exception {
  const AiApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AiNetworkException extends AiApiException {
  const AiNetworkException([
    super.message = 'Tidak dapat terhubung ke server AI',
  ]);
}

class AiTimeoutException extends AiApiException {
  const AiTimeoutException([
    super.message = 'Proses ekstraksi AI memakan waktu terlalu lama',
  ]);
}

class AiServerException extends AiApiException {
  const AiServerException(
    this.statusCode, [
    super.message = 'Server AI mengalami kendala',
  ]);
  final int? statusCode;
}

class AiSchemaException extends AiApiException {
  const AiSchemaException([super.message = 'Format data dari AI tidak valid']);
}

/// HTTP Client untuk komunikasi mobile -> Go Backend `/api/v1/ai/parse`.
class AiApiClient {
  AiApiClient({
    Dio? dio,
    String? baseUrl,
    Future<String> Function()? timezoneResolver,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl:
                   baseUrl ??
                   const String.fromEnvironment(
                     'AI_API_BASE_URL',
                     defaultValue: 'http://10.0.2.2:8080',
                   ),
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 15),
               headers: {'Content-Type': 'application/json'},
             ),
           ),
       _timezoneResolver =
           timezoneResolver ??
           (() async => (await FlutterTimezone.getLocalTimezone()).identifier);

  final Dio _dio;
  final Future<String> Function() _timezoneResolver;

  Future<List<ExtractedTask>> parseBrainDump(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw const AiSchemaException('Teks tidak boleh kosong');
    }

    String timezone = 'UTC';
    try {
      timezone = await _timezoneResolver();
    } catch (_) {
      // Fallback ke UTC jika platform channel gagal
    }

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/ai/parse',
        data: {'text': trimmed, 'timezone': timezone, 'nowMs': nowMs},
      );

      final data = response.data;
      if (data == null || data['items'] is! List) {
        throw const AiSchemaException(
          'Format respons server tidak memiliki daftar tugas',
        );
      }

      final items = data['items'] as List<dynamic>;
      return items
          .map((item) => ExtractedTask.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const AiTimeoutException();
      }

      if (e.type == DioExceptionType.connectionError) {
        throw const AiNetworkException();
      }

      final status = e.response?.statusCode;
      if (status == 422) {
        throw const AiSchemaException(
          'Keluaran AI tidak memenuhi skema yang ditentukan',
        );
      }

      if (status != null && status >= 500) {
        throw AiServerException(
          status,
          'Server backend mengalami gangguan (HTTP $status)',
        );
      }

      throw AiServerException(
        status,
        e.message ?? 'Terjadi kesalahan komunikasi API',
      );
    }
  }
}

final aiApiClientProvider = Provider<AiApiClient>((ref) {
  return AiApiClient();
});
