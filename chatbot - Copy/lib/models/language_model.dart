class Language {
  final String name;
  final String code;
  final String nativeName;
  final String sttLocale; // locale ID for speech recognition / TTS (platform)

  const Language({
    required this.name,
    required this.code,
    required this.nativeName,
    required this.sttLocale,
  });
}

class LanguageConstants {
  static const List<Language> supportedLanguages = [
    // Locale codes are typical Android locales; adjust if your device uses different ones
    Language(
        name: 'English', code: 'en', nativeName: 'English', sttLocale: 'en-US'),
    Language(
        name: 'Hindi', code: 'hi', nativeName: 'हिंदी', sttLocale: 'hi-IN'),
    Language(
        name: 'Tamil', code: 'ta', nativeName: 'தமிழ்', sttLocale: 'ta-IN'),
    Language(
        name: 'Telugu', code: 'te', nativeName: 'తెలుగు', sttLocale: 'te-IN'),
    Language(
        name: 'Kannada', code: 'kn', nativeName: 'ಕನ್ನಡ', sttLocale: 'kn-IN'),
    Language(
        name: 'Malayalam',
        code: 'ml',
        nativeName: 'മലയാളം',
        sttLocale: 'ml-IN'),
    Language(
        name: 'Bengali', code: 'bn', nativeName: 'বাংলা', sttLocale: 'bn-IN'),
    Language(
        name: 'Gujarati',
        code: 'gu',
        nativeName: 'ગુજરાતી',
        sttLocale: 'gu-IN'),
    Language(
        name: 'Marathi', code: 'mr', nativeName: 'मराठी', sttLocale: 'mr-IN'),
    Language(
        name: 'Punjabi', code: 'pa', nativeName: 'ਪੰਜਾਬੀ', sttLocale: 'pa-IN'),
    Language(
        name: 'Urdu', code: 'ur', nativeName: 'اردو', sttLocale: 'ur-PK'),
    Language(
        name: 'Spanish',
        code: 'es',
        nativeName: 'Español',
        sttLocale: 'es-ES'),
    Language(
        name: 'French',
        code: 'fr',
        nativeName: 'Français',
        sttLocale: 'fr-FR'),
    Language(
        name: 'German',
        code: 'de',
        nativeName: 'Deutsch',
        sttLocale: 'de-DE'),
    Language(
        name: 'Chinese', code: 'zh', nativeName: '中文', sttLocale: 'zh-CN'),
    Language(
        name: 'Japanese',
        code: 'ja',
        nativeName: '日本語',
        sttLocale: 'ja-JP'),
  ];

  static Language getLanguageByCode(String code) {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => supportedLanguages.first, // Default to English
    );
  }

  static Language getLanguageByName(String name) {
    return supportedLanguages.firstWhere(
      (lang) => lang.name == name,
      orElse: () => supportedLanguages.first, // Default to English
    );
  }
}


