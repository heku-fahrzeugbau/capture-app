import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceService extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _transcript = '';
  String? _error;

  bool get isListening => _isListening;
  String get transcript => _transcript;
  String? get error => _error;

  Future<void> initialize() async {
    final available = await _speechToText.initialize(
      onError: (error) {
        _error = error.errorMsg;
        notifyListeners();
      },
      onStatus: (status) {
        print('✅ Speech status: $status');
      },
    );

    if (!available) {
      _error = 'Spracherkennung nicht verfügbar';
      notifyListeners();
    }
  }

  Future<void> startListening() async {
    if (_isListening) return;

    _transcript = '';
    _error = null;
    _isListening = true;
    notifyListeners();

    try {
      await _speechToText.listen(
        onResult: (result) {
          _transcript = result.recognizedWords;
          notifyListeners();
        },
        localeId: 'de_DE',
      );
    } catch (e) {
      _error = 'Fehler beim Starten: $e';
      _isListening = false;
      notifyListeners();
    }
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
    _isListening = false;
    notifyListeners();
  }
}
