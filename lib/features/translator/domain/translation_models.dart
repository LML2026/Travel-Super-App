class TravelLanguage {
  const TravelLanguage({
    required this.code,
    required this.name,
  });

  final String code;
  final String name;
}

class TranslatorContext {
  const TranslatorContext({
    this.destination,
    this.contextLabel,
    this.initialText,
  });

  final String? destination;
  final String? contextLabel;
  final String? initialText;
}

class TranslationRequest {
  const TranslationRequest({
    required this.text,
    required this.sourceLanguageCode,
    required this.targetLanguageCode,
    this.autoDetect = false,
  });

  final String text;
  final String sourceLanguageCode;
  final String targetLanguageCode;
  final bool autoDetect;
}

class TranslationResponse {
  const TranslationResponse({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguageCode,
    required this.targetLanguageCode,
    required this.isDemo,
    this.detectedLanguageCode,
  });

  final String originalText;
  final String translatedText;
  final String sourceLanguageCode;
  final String targetLanguageCode;
  final String? detectedLanguageCode;
  final bool isDemo;
}

class SavedTranslation {
  const SavedTranslation({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguageCode,
    required this.targetLanguageCode,
    required this.createdAt,
    this.isFavourite = false,
    this.contextLabel,
  });

  final String id;
  final String sourceText;
  final String translatedText;
  final String sourceLanguageCode;
  final String targetLanguageCode;
  final DateTime createdAt;
  final bool isFavourite;
  final String? contextLabel;

  SavedTranslation copyWith({
    String? id,
    String? sourceText,
    String? translatedText,
    String? sourceLanguageCode,
    String? targetLanguageCode,
    DateTime? createdAt,
    bool? isFavourite,
    String? contextLabel,
  }) {
    return SavedTranslation(
      id: id ?? this.id,
      sourceText: sourceText ?? this.sourceText,
      translatedText: translatedText ?? this.translatedText,
      sourceLanguageCode: sourceLanguageCode ?? this.sourceLanguageCode,
      targetLanguageCode: targetLanguageCode ?? this.targetLanguageCode,
      createdAt: createdAt ?? this.createdAt,
      isFavourite: isFavourite ?? this.isFavourite,
      contextLabel: contextLabel ?? this.contextLabel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceText': sourceText,
      'translatedText': translatedText,
      'sourceLanguageCode': sourceLanguageCode,
      'targetLanguageCode': targetLanguageCode,
      'createdAt': createdAt.toIso8601String(),
      'isFavourite': isFavourite,
      'contextLabel': contextLabel,
    };
  }

  factory SavedTranslation.fromJson(Map<String, dynamic> json) {
    return SavedTranslation(
      id: json['id'] as String,
      sourceText: json['sourceText'] as String,
      translatedText: json['translatedText'] as String,
      sourceLanguageCode: json['sourceLanguageCode'] as String,
      targetLanguageCode: json['targetLanguageCode'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isFavourite: json['isFavourite'] as bool? ?? false,
      contextLabel: json['contextLabel'] as String?,
    );
  }
}

class ConversationTurn {
  const ConversationTurn({
    required this.id,
    required this.speakerLabel,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguageCode,
    required this.targetLanguageCode,
    required this.createdAt,
  });

  final String id;
  final String speakerLabel;
  final String sourceText;
  final String translatedText;
  final String sourceLanguageCode;
  final String targetLanguageCode;
  final DateTime createdAt;
}

class PhrasebookPhrase {
  const PhrasebookPhrase({
    required this.category,
    required this.text,
  });

  final String category;
  final String text;
}

const travelLanguages = <TravelLanguage>[
  TravelLanguage(code: 'auto', name: 'Auto-detect'),
  TravelLanguage(code: 'en', name: 'English'),
  TravelLanguage(code: 'fr', name: 'French'),
  TravelLanguage(code: 'es', name: 'Spanish'),
  TravelLanguage(code: 'it', name: 'Italian'),
  TravelLanguage(code: 'de', name: 'German'),
  TravelLanguage(code: 'pt', name: 'Portuguese'),
  TravelLanguage(code: 'ja', name: 'Japanese'),
];

String languageNameFor(String code) {
  return travelLanguages
      .firstWhere(
        (language) => language.code == code,
        orElse: () => TravelLanguage(code: code, name: code.toUpperCase()),
      )
      .name;
}
