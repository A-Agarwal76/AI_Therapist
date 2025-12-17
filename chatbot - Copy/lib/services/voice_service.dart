import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:chonoes/models/language_model.dart';

class VoiceService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  bool _isListening = false;
  bool _isSpeaking = false;
  Language _currentLanguage = LanguageConstants.supportedLanguages.first;

  // TTS configuration (can be controlled from UI)
  double _speechRate = 0.8; // Default: Normal
  double _pitch = 1.0; // Default: Neutral
  String _voiceProfile = 'Neutral';

  Language get currentLanguage => _currentLanguage;
  double get speechRate => _speechRate;
  double get pitch => _pitch;
  String get voiceProfile => _voiceProfile;

  void setLanguage(Language language) {
    _currentLanguage = language;
    _configureTTS();
  }

  void setSpeechRate(double rate) {
    _speechRate = rate.clamp(0.3, 1.5);
    _configureTTS();
    notifyListeners();
  }

  void setVoiceProfile({required String profile, required double pitch}) {
    _voiceProfile = profile;
    _pitch = pitch.clamp(0.7, 1.3);
    _configureTTS();
    notifyListeners();
  }

  Future<void> _configureTTS() async {
    await _flutterTts.setLanguage(_currentLanguage.code);
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(_pitch);
  }

  /// Initialize speech recognition
  Future<bool> initializeSpeech() async {
    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      log('Microphone permission denied');
      return false;
    }

    bool available = await _speechToText.initialize(
      onError: (error) {
        log('Speech recognition error: $error');
      },
      onStatus: (status) {
        log('Speech recognition status: $status');
      },
    );

    if (available) {
      await _configureTTS();
    }

    return available;
  }

  /// Start listening for speech input
  Future<void> startListening({
    required Function(String) onResult,
    Function()? onError,
  }) async {
    if (_isListening) {
      stopListening();
      return;
    }

    if (!await _speechToText.initialize()) {
      onError?.call();
      return;
    }

    _isListening = true;
    await _speechToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          _isListening = false;
          onResult(result.recognizedWords);
        }
      },
      // Use language-specific locale (e.g., hi-IN, ta-IN) so STT listens in the selected language
      localeId: _currentLanguage.sttLocale,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  /// Stop listening for speech input
  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
  }

  bool get isListening => _isListening;

  /// Speak text using TTS (non-blocking, faster)
  Future<void> speak(String text, {String? languageCode}) async {
    if (_isSpeaking) {
      await stopSpeaking();
    }

    final langCode = languageCode ?? _currentLanguage.code;

    // Skip Sarvam TTS check to save time - use FlutterTts directly
    // This makes voice output non-blocking and faster
    _speakWithFlutterTts(text, langCode);
  }

  Future<void> _speakWithFlutterTts(String text, String languageCode) async {
    _isSpeaking = true;
    notifyListeners();
    await _flutterTts.setLanguage(languageCode);
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setPitch(_pitch);
    await _flutterTts.speak(text);

    // Wait for speech to complete
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
      notifyListeners();
    }
  }

  bool get isSpeaking => _isSpeaking;

  /// Dispose resources
  @override
  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
    super.dispose();
  }
}
