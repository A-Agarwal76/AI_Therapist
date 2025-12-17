import 'package:flutter/material.dart';
import 'package:chonoes/models/language_model.dart';

class LanguageSelector extends StatelessWidget {
  final Language selectedLanguage;
  final Function(Language) onLanguageChanged;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Language>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            selectedLanguage.code.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      itemBuilder: (context) {
        return LanguageConstants.supportedLanguages.map((language) {
          return PopupMenuItem<Language>(
            value: language,
            child: Row(
              children: [
                if (language.code == selectedLanguage.code)
                  const Icon(Icons.check, color: Color(0xFF667eea), size: 20)
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 8),
                Text(
                  '${language.name} (${language.nativeName})',
                  style: TextStyle(
                    fontWeight: language.code == selectedLanguage.code
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      onSelected: onLanguageChanged,
    );
  }
}


