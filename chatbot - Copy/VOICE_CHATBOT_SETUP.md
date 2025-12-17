# Multilingual Voice Chatbot Setup Guide

## Overview
The Flutter app has been transformed into a multilingual voice chatbot that supports:
- 🎙️ Voice input (speech-to-text)
- 🔊 Voice output (text-to-speech)
- 🌐 16+ languages support
- 🔄 Automatic translation using Sarvam AI
- 💬 Text-based chat as fallback

## New Features

### 1. Language Selection
- Select from 16 supported languages
- Languages include: English, Hindi, Tamil, Telugu, Kannada, Malayalam, Bengali, Gujarati, Marathi, Punjabi, Urdu, Spanish, French, German, Chinese, Japanese
- Language selector in the app bar and input area

### 2. Voice Input
- Tap the microphone button to start voice recording
- Speak in your selected language
- Automatic transcription to text
- Visual indicator when listening (red microphone icon)

### 3. Voice Output
- Automatic text-to-speech for assistant responses
- Toggle voice output on/off with volume button
- Play/stop buttons on each assistant message
- Uses Sarvam AI TTS for high-quality voice synthesis

### 4. Automatic Translation
- User input translated to English for processing
- Assistant response translated back to selected language
- Seamless multilingual conversation

## Setup Instructions

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure API Keys

Edit `lib/secrets.dart` and add your Sarvam AI API key:

```dart
const String SARVAM_API_KEY = 'YOUR_ACTUAL_SARVAM_API_KEY';
```

Get your API key from: https://sarvam.ai

### 3. Permissions

#### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

#### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access for voice input</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>We need speech recognition for voice input</string>
```

### 4. Run the App
```bash
flutter run
```

## New Files Created

1. **lib/models/language_model.dart** - Language constants and models
2. **lib/services/sarvam_service.dart** - Sarvam AI API integration
3. **lib/services/voice_service.dart** - Voice input/output management
4. **lib/widgets/language_selector.dart** - Language selection UI

## Modified Files

1. **pubspec.yaml** - Added voice dependencies
2. **lib/secrets.dart** - Added Sarvam API key configuration
3. **lib/backend/send_message.dart** - Added translation support
4. **lib/pages/homepage_1.dart** - Converted to StatefulWidget with voice features
5. **lib/component/chats_box.dart** - Added voice playback buttons

## Dependencies Added

- `speech_to_text: ^6.6.0` - Speech recognition
- `flutter_tts: ^4.0.2` - Text-to-speech
- `record: ^5.1.2` - Audio recording
- `path_provider: ^2.1.2` - File paths
- `permission_handler: ^11.3.0` - Permission management

## Usage

1. **Select Language**: Tap the language selector in the app bar or input area
2. **Voice Input**: Tap the microphone button and speak
3. **Text Input**: Type your message normally
4. **Voice Output**: Toggle the volume button to enable/disable auto-play
5. **Play Response**: Tap the speaker icon on any assistant message to replay

## Troubleshooting

### Voice Input Not Working
- Check microphone permissions
- Ensure device has a working microphone
- Try restarting the app

### Voice Output Not Working
- Check if voice output is enabled (volume icon)
- Verify Sarvam API key is configured
- Check internet connection for Sarvam TTS

### Translation Not Working
- Verify Sarvam API key is set correctly
- Check internet connection
- Ensure language is supported

## Notes

- The app uses FlutterTts as a fallback if Sarvam TTS is unavailable
- Voice recognition requires internet connection for some languages
- First-time voice setup may take a moment to initialize

## API Endpoints Used

- **Translation**: `https://api.sarvam.ai/v1/translate`
- **TTS**: `https://api.sarvam.ai/v1/tts`
- **Language Detection**: `https://api.sarvam.ai/v1/detect-language`

Adjust these in `lib/services/sarvam_service.dart` if your API uses different endpoints.


