import 'dart:convert';
import 'dart:developer';
import 'package:chonoes/secrets.dart';
import 'package:http/http.dart' as http;

class SarvamService {
  static const String _baseUrl = SARVAM_BASE_URL;
  static const String _apiKey = SARVAM_API_KEY;

  /// Translate text from source language to target language
  static Future<String?> translateText({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_SARVAM_API_KEY_HERE') {
      log('Sarvam API key not configured');
      return null;
    }

    try {
      final url = Uri.parse('$_baseUrl/translate');
      final headers = {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'text': text,
        'source_language': sourceLang,
        'target_language': targetLang,
      });

      final response = await http.post(url, headers: headers, body: body).timeout(
        const Duration(seconds: 8), // Reduced from 30 to 8 seconds for faster response
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['translated_text'] as String?;
      } else {
        log('Translation failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      log('Translation error: $e');
      return null;
    }
  }

  /// Generate TTS audio bytes for given text
  static Future<List<int>?> generateTTS({
    required String text,
    required String languageCode,
  }) async {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_SARVAM_API_KEY_HERE') {
      log('Sarvam API key not configured');
      return null;
    }

    try {
      final url = Uri.parse('$_baseUrl/tts');
      final headers = {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'text': text,
        'language': languageCode,
        'voice': 'default',
      });

      final response = await http.post(url, headers: headers, body: body).timeout(
        const Duration(seconds: 8), // Reduced from 30 to 8 seconds for faster response
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        log('TTS generation failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      log('TTS error: $e');
      return null;
    }
  }

  /// Detect language of given text
  static Future<String?> detectLanguage(String text) async {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_SARVAM_API_KEY_HERE') {
      log('Sarvam API key not configured');
      return null;
    }

    try {
      final url = Uri.parse('$_baseUrl/detect-language');
      final headers = {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({'text': text});

      final response = await http.post(url, headers: headers, body: body).timeout(
        const Duration(seconds: 8), // Reduced from 30 to 8 seconds for faster response
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['language_code'] as String?;
      } else {
        log('Language detection failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      log('Language detection error: $e');
      return null;
    }
  }
}

