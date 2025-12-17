import 'dart:convert';
import 'dart:developer';
import 'package:chonoes/models/user_model.dart';
import 'package:chonoes/secrets.dart';
import 'package:http/http.dart' as http;
import 'package:chonoes/models/chat_model.dart';
import 'package:chonoes/services/sarvam_service.dart';

// ignore: non_constant_identifier_names
Future<ChatModel> getdata(ChatModel message, User chronoes, {String? sourceLanguage, String? targetLanguage}) async {
  late ChatModel chatModel;

  // Validate API key first
  if (APIKEY.isEmpty) {
    log('ERROR: API key is empty!');
    return ChatModel(
        user: chronoes,
        createAt: DateTime.now(),
        text: 'Error: API key is not configured. Please check secrets.dart',
        isSender: false);
  }

  log('API Key check: ${APIKEY.substring(0, APIKEY.length > 10 ? 10 : APIKEY.length)}... (length: ${APIKEY.length})');

  // Translate user message to English for processing if needed
  // Skip translation if already in English to save time
  String messageText = message.text;
  if (sourceLanguage != null && sourceLanguage != 'en' && messageText.isNotEmpty) {
    try {
      final translated = await SarvamService.translateText(
        text: messageText,
        sourceLang: sourceLanguage,
        targetLang: 'en',
      ).timeout(const Duration(seconds: 5)); // Add timeout to prevent hanging
      if (translated != null && translated.isNotEmpty) {
        messageText = translated;
        log('Translated message to English: $messageText');
      }
    } catch (e) {
      log('Translation timeout/error, using original text: $e');
      // Continue with original text if translation fails
    }
  }

  const headers = {'Content-Type': 'application/json'};

  // Use API key from secrets.dart directly in URL
  // Using v1beta with gemini-2.5-flash model
  final url =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$APIKEY";

  log('Request URL: ${url.substring(0, url.length > 100 ? 100 : url.length)}...');
  log('API key length: ${APIKEY.length}');

  var body = {
    "contents": [
      {
        "parts": [
          {
            "text":
                "You are chronoes, a warm and compassionate mental health companion. Respond naturally and conversationally, like a caring friend. Keep responses concise (2-3 sentences) but make them feel genuine and human. Use a warm, understanding tone. Be supportive and non-judgmental. If someone expresses thoughts of self-harm or suicide, encourage them to seek immediate professional help. Remember: you are not a replacement for professional therapy, but a supportive companion.\n\nUser message: $messageText"
          }
        ]
      }
    ],
    "generationConfig": {"temperature": 0.9, "topP": 0.95, "topK": 40}
  };
  try {
    log('Sending POST request to Gemini API...');
    final response = await http
        .post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    )
        .timeout(
      const Duration(seconds: 20), // Reduced from 30 to 20 seconds for faster response
      onTimeout: () {
        throw Exception('Request timeout after 20 seconds');
      },
    );

    log('Response status: ${response.statusCode}');
    log('Response body length: ${response.body.length}');
    if (response.body.length < 500) {
      log('Response body: ${response.body}');
    }

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      if (result["candidates"] != null &&
          result["candidates"].isNotEmpty &&
          result["candidates"][0]['content'] != null &&
          result["candidates"][0]['content']['parts'] != null &&
          result["candidates"][0]['content']['parts'].isNotEmpty) {
        var output = result["candidates"][0]['content']['parts'][0]['text'];
        
        // Translate response back to target language if needed
        // Add timeout to prevent hanging and return faster
        String finalOutput = output;
        if (targetLanguage != null && targetLanguage != 'en' && output.isNotEmpty) {
          try {
            final translated = await SarvamService.translateText(
              text: output,
              sourceLang: 'en',
              targetLang: targetLanguage,
            ).timeout(const Duration(seconds: 5)); // Add timeout for faster response
            if (translated != null && translated.isNotEmpty) {
              finalOutput = translated;
              log('Translated response to $targetLanguage: $finalOutput');
            }
          } catch (e) {
            log('Response translation timeout/error, using English: $e');
            // Continue with English if translation fails
          }
        }
        
        chatModel = ChatModel(
            user: chronoes,
            createAt: DateTime.now(),
            text: finalOutput,
            isSender: false);
        log('Success: ${chatModel.text.substring(0, chatModel.text.length > 50 ? 50 : chatModel.text.length)}...');
      } else {
        log('Error: Invalid response structure');
        chatModel = ChatModel(
            user: chronoes,
            createAt: DateTime.now(),
            text: 'Invalid response from API',
            isSender: false);
      }
    } else {
      log('Error: HTTP ${response.statusCode}');
      log('Error response body: ${response.body}');

      String errorMessage = 'Unable to fetch data';
      try {
        var errorBody = jsonDecode(response.body);
        if (errorBody['error'] != null) {
          if (errorBody['error']['message'] != null) {
            errorMessage = errorBody['error']['message'];
          } else if (errorBody['error']['status'] != null) {
            errorMessage = 'API Error: ${errorBody['error']['status']}';
          }
        }
      } catch (e) {
        errorMessage =
            'HTTP ${response.statusCode}: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}';
      }

      // Special handling for common API key errors
      if (response.statusCode == 401 || response.statusCode == 403) {
        errorMessage =
            'API key is invalid or expired. Please check your API key in secrets.dart';
      }

      chatModel = ChatModel(
          user: chronoes,
          createAt: DateTime.now(),
          text: errorMessage,
          isSender: false);
    }
  } catch (e, stackTrace) {
    log('Exception: $e');
    log('Exception type: ${e.runtimeType}');
    log('Stack trace: $stackTrace');
    String errorMessage = 'Error: ${e.toString()}';

    // Provide more helpful error messages
    if (e.toString().contains('API key') ||
        e.toString().contains('401') ||
        e.toString().contains('403')) {
      errorMessage =
          'API key error. Please verify your API key in secrets.dart is valid.';
    } else if (e.toString().contains('network') ||
        e.toString().contains('SocketException') ||
        e.toString().contains('Failed to fetch') ||
        e.toString().contains('ClientException')) {
      errorMessage =
          'Network error. Please check your internet connection and try again.';
    } else if (e.toString().contains('timeout') ||
        e.toString().contains('TimeoutException')) {
      errorMessage =
          'Request timeout. The server took too long to respond. Please try again.';
    } else if (e.toString().contains('404') ||
        e.toString().contains('not found')) {
      errorMessage =
          'API endpoint not found. The model may not be available. Please check your API key permissions.';
    }

    chatModel = ChatModel(
        user: chronoes,
        createAt: DateTime.now(),
        text: errorMessage,
        isSender: false);
  }
  return chatModel;
}

// Note: This function uses direct API calls instead of Gemini SDK
// Currently not used since image functionality was removed, but kept for potential future use
Future<ChatModel> sendImageData(ChatModel message, User chonoes) async {
  ChatModel chatModel = ChatModel(
      text: 'unable to fetch data',
      user: chonoes,
      createAt: DateTime.now(),
      isSender: false);

  try {
    // Validate API key
    if (APIKEY.isEmpty) {
      throw Exception('API key is empty. Please check secrets.dart');
    }

    // Use direct API call with API key from secrets.dart
    // Using v1beta API with gemini-2.5-flash model for vision
    final url =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$APIKEY";

    log('Using direct API with key: ${APIKEY.substring(0, 10)}... (length: ${APIKEY.length})');

    // Convert image to base64
    final imageBytes = await message.file!.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    String mentalHealthPrompt =
        "You are chronoes, a warm and compassionate mental health companion. Respond naturally and conversationally, like a caring friend. Keep responses concise (2-3 sentences) but make them feel genuine and human make the answers as creative as possible and try to make it unique. User message: ${message.text}";

    var body = {
      "contents": [
        {
          "parts": [
            {"text": mentalHealthPrompt},
            {
              "inline_data": {"mime_type": "image/jpeg", "data": base64Image}
            }
          ]
        }
      ],
      "generationConfig": {"temperature": 0.9, "topP": 0.95, "topK": 40}
    };

    const headers = {'Content-Type': 'application/json'};

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    log('Image API Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      if (result["candidates"] != null &&
          result["candidates"].isNotEmpty &&
          result["candidates"][0]['content'] != null &&
          result["candidates"][0]['content']['parts'] != null &&
          result["candidates"][0]['content']['parts'].isNotEmpty) {
        var output = result["candidates"][0]['content']['parts'][0]['text'];
        log('Image response received');
        chatModel = ChatModel(
            text: output,
            user: chonoes,
            createAt: DateTime.now(),
            isSender: false);
      } else {
        log('Error: Invalid image response structure');
        chatModel = ChatModel(
            text: 'Invalid response from API',
            user: chonoes,
            createAt: DateTime.now(),
            isSender: false);
      }
    } else {
      log('Error: HTTP ${response.statusCode} - ${response.body}');
      var errorBody = jsonDecode(response.body);
      String errorMessage = 'Unable to fetch data';
      if (errorBody['error'] != null && errorBody['error']['message'] != null) {
        errorMessage = errorBody['error']['message'];
      }
      chatModel = ChatModel(
          text: errorMessage,
          user: chonoes,
          createAt: DateTime.now(),
          isSender: false);
    }
  } catch (e) {
    log('Image error: $e');
    chatModel = ChatModel(
        text: 'Error: ${e.toString()}',
        user: chonoes,
        createAt: DateTime.now(),
        isSender: false);
  }

  return chatModel;
}
