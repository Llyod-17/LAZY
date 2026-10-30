import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Service wrapper untuk Speech-to-Text on-device Android.
/// Memastikan kegagalan mikrofon atau penolakan izin tidak menyebabkan crash,
/// melainkan fallback ramah ke input keyboard manual.
class SpeechService {
  SpeechService({SpeechToText? speech}) : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;

  bool get isAvailable => _speech.isAvailable;
  bool get isListening => _speech.isListening;

  /// Inisialisasi engine STT dan cek izin mikrofon.
  Future<bool> init({
    Function(String errorMsg)? onError,
    Function(String status)? onStatus,
  }) async {
    try {
      return await _speech.initialize(
        onError: (SpeechRecognitionError error) {
          if (onError != null) {
            onError(error.errorMsg);
          }
        },
        onStatus: (String status) {
          if (onStatus != null) {
            onStatus(status);
          }
        },
      );
    } catch (e) {
      debugPrint('SpeechService init error: $e');
      return false;
    }
  }

  /// Mulai merekam suara dengan callback teks transkripsi (real-time/parsial).
  Future<void> startListening({
    required Function(String words) onResult,
    Function(String errorMsg)? onError,
    String? localeId,
  }) async {
    if (!_speech.isAvailable) {
      final initialized = await init(onError: onError);
      if (!initialized) {
        if (onError != null) {
          onError(
            'Mikrofon tidak tersedia atau izin ditolak. Silakan gunakan input teks.',
          );
        }
        return;
      }
    }

    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          onResult(result.recognizedWords);
        },
        listenOptions: SpeechListenOptions(localeId: localeId ?? 'id_ID'),
      );
    } catch (e) {
      if (onError != null) {
        onError('Gagal memulai perekaman: $e');
      }
    }
  }

  /// Berhenti mendengarkan dan kunci hasil saat ini.
  Future<void> stopListening() async {
    try {
      await _speech.stop();
    } catch (e) {
      debugPrint('SpeechService stop error: $e');
    }
  }

  /// Batalkan sesi mendengarkan dan buang buffer audio.
  Future<void> cancel() async {
    try {
      await _speech.cancel();
    } catch (e) {
      debugPrint('SpeechService cancel error: $e');
    }
  }
}
