import 'package:flutter/material.dart';

class TranslationLanguage {
  final String code;
  final String nativeName;
  final Locale locale;
  final bool isAutoDetect;

  const TranslationLanguage({
    required this.code,
    required this.nativeName,
    required this.locale,
    this.isAutoDetect = false,
  });

  static const autoDetect = TranslationLanguage(
    code: 'auto',
    nativeName: 'Auto-detect',
    locale: Locale('en'),
    isAutoDetect: true,
  );

  static const supported = <TranslationLanguage>[
    TranslationLanguage(
      code: 'en',
      nativeName: 'English',
      locale: Locale('en'),
    ),
    TranslationLanguage(
      code: 'it',
      nativeName: 'Italiano',
      locale: Locale('it'),
    ),
    TranslationLanguage(
      code: 'es',
      nativeName: 'Español',
      locale: Locale('es'),
    ),
    TranslationLanguage(
      code: 'fr',
      nativeName: 'Français',
      locale: Locale('fr'),
    ),
    TranslationLanguage(
      code: 'de',
      nativeName: 'Deutsch',
      locale: Locale('de'),
    ),
    TranslationLanguage(
      code: 'ru',
      nativeName: 'Русский',
      locale: Locale('ru'),
    ),
    TranslationLanguage(
      code: 'zh_CN',
      nativeName: '简体中文',
      locale: Locale('zh', 'CN'),
    ),
    TranslationLanguage(code: 'ja', nativeName: '日本語', locale: Locale('ja')),
    TranslationLanguage(code: 'ko', nativeName: '한국어', locale: Locale('ko')),
    TranslationLanguage(
      code: 'pt',
      nativeName: 'Português',
      locale: Locale('pt'),
    ),
    TranslationLanguage(
      code: 'ar',
      nativeName: 'العربية',
      locale: Locale('ar'),
    ),
    TranslationLanguage(code: 'tr', nativeName: 'Türkçe', locale: Locale('tr')),
    TranslationLanguage(code: 'pl', nativeName: 'Polski', locale: Locale('pl')),
    TranslationLanguage(
      code: 'nl',
      nativeName: 'Nederlands',
      locale: Locale('nl'),
    ),
    TranslationLanguage(code: 'hi', nativeName: 'हिन्दी', locale: Locale('hi')),
    TranslationLanguage(
      code: 'ka',
      nativeName: 'ქართული',
      locale: Locale('ka'),
    ),
    TranslationLanguage(code: 'fa', nativeName: 'فارسی', locale: Locale('fa')),
    TranslationLanguage(
      code: 'hy',
      nativeName: 'Հայերեն',
      locale: Locale('hy'),
    ),
    TranslationLanguage(
      code: 'uk',
      nativeName: 'Українська',
      locale: Locale('uk'),
    ),
  ];

  static TranslationLanguage? byCode(String code) {
    for (final language in supported) {
      if (language.code == code) return language;
    }
    return null;
  }

  static TranslationLanguage defaultTarget(Locale appLocale) {
    return byCode(
          appLocale.countryCode == null
              ? appLocale.languageCode
              : '${appLocale.languageCode}_${appLocale.countryCode}',
        ) ??
        supported.first;
  }
}
