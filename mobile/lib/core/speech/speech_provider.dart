import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'speech_service.dart';

final speechServiceProvider = Provider<SpeechService>((ref) {
  return SpeechService();
});
