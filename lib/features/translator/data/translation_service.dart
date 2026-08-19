import '../domain/translation_models.dart';

abstract interface class TranslationService {
  Future<TranslationResponse> translate(TranslationRequest request);
}

class DemoTranslationService implements TranslationService {
  const DemoTranslationService();

  @override
  Future<TranslationResponse> translate(TranslationRequest request) async {
    final text = request.text.trim();
    if (text.isEmpty) {
      throw ArgumentError('Enter text to translate.');
    }

    final sourceCode =
        request.autoDetect || request.sourceLanguageCode == 'auto'
            ? _detectLanguage(text)
            : request.sourceLanguageCode;
    final targetCode = request.targetLanguageCode;
    final translated = _knownTranslation(text, targetCode) ??
        _fallbackTranslation(
          text: text,
          sourceCode: sourceCode,
          targetCode: targetCode,
        );

    return TranslationResponse(
      originalText: text,
      translatedText: translated,
      sourceLanguageCode: sourceCode,
      targetLanguageCode: targetCode,
      detectedLanguageCode:
          request.autoDetect || request.sourceLanguageCode == 'auto'
              ? sourceCode
              : null,
      isDemo: true,
    );
  }

  String _fallbackTranslation({
    required String text,
    required String sourceCode,
    required String targetCode,
  }) {
    final prefix = switch (targetCode) {
      'fr' => 'Traduction demo',
      'es' => 'Traduccion demo',
      'it' => 'Traduzione demo',
      'de' => 'Demo-Ubersetzung',
      'pt' => 'Traducao demo',
      'ja' => 'デモ翻訳',
      _ => 'Demo translation',
    };
    return '$prefix: $text';
  }

  String _detectLanguage(String text) {
    final lower = text.toLowerCase();
    if (_containsAny(lower, ['bonjour', 'merci', 's il vous plait'])) {
      return 'fr';
    }
    if (_containsAny(lower, ['hola', 'gracias', 'por favor'])) {
      return 'es';
    }
    if (_containsAny(lower, ['ciao', 'grazie', 'per favore'])) {
      return 'it';
    }
    if (_containsAny(lower, ['hallo', 'danke', 'bitte'])) {
      return 'de';
    }
    return 'en';
  }

  String? _knownTranslation(String text, String targetCode) {
    final normalized = text.trim().toLowerCase();
    return _translations[targetCode]?[normalized];
  }

  bool _containsAny(String value, List<String> needles) {
    return needles.any(value.contains);
  }
}

const phrasebookPhrases = <PhrasebookPhrase>[
  PhrasebookPhrase(category: 'Airport', text: 'Where is the check-in desk?'),
  PhrasebookPhrase(category: 'Airport', text: 'Is my flight on time?'),
  PhrasebookPhrase(category: 'Airport', text: 'Where is baggage claim?'),
  PhrasebookPhrase(category: 'Hotel', text: 'I have a reservation.'),
  PhrasebookPhrase(category: 'Hotel', text: 'Can I check in early?'),
  PhrasebookPhrase(category: 'Hotel', text: 'What time is check-out?'),
  PhrasebookPhrase(category: 'Restaurant', text: 'A table for two, please.'),
  PhrasebookPhrase(category: 'Restaurant', text: 'Can I see the menu?'),
  PhrasebookPhrase(category: 'Restaurant', text: 'I have a food allergy.'),
  PhrasebookPhrase(
      category: 'Taxi/Transport', text: 'Please take me to this address.'),
  PhrasebookPhrase(category: 'Taxi/Transport', text: 'How much will it cost?'),
  PhrasebookPhrase(category: 'Taxi/Transport', text: 'Please stop here.'),
  PhrasebookPhrase(category: 'Shopping', text: 'How much is this?'),
  PhrasebookPhrase(category: 'Shopping', text: 'Can I pay by card?'),
  PhrasebookPhrase(
      category: 'Directions', text: 'Where is the nearest station?'),
  PhrasebookPhrase(category: 'Directions', text: 'Can you show me on the map?'),
  PhrasebookPhrase(category: 'Medical/Emergency', text: 'I need medical help.'),
  PhrasebookPhrase(
      category: 'Medical/Emergency', text: 'Please call emergency services.'),
  PhrasebookPhrase(
      category: 'General conversation', text: 'Hello, can you help me?'),
  PhrasebookPhrase(
      category: 'General conversation', text: 'Thank you very much.'),
];

const _translations = <String, Map<String, String>>{
  'fr': {
    'hello, can you help me?': 'Bonjour, pouvez-vous m aider ?',
    'thank you very much.': 'Merci beaucoup.',
    'where is the check-in desk?': 'Ou est le comptoir d enregistrement ?',
    'is my flight on time?': 'Mon vol est-il a l heure ?',
    'where is baggage claim?': 'Ou se trouve la livraison des bagages ?',
    'i have a reservation.': 'J ai une reservation.',
    'can i check in early?': 'Puis-je arriver plus tot ?',
    'what time is check-out?': 'A quelle heure est le depart ?',
    'a table for two, please.': 'Une table pour deux, s il vous plait.',
    'can i see the menu?': 'Puis-je voir le menu ?',
    'i have a food allergy.': 'J ai une allergie alimentaire.',
    'please take me to this address.':
        'Emmenez-moi a cette adresse, s il vous plait.',
    'how much will it cost?': 'Combien cela coutera-t-il ?',
    'please stop here.': 'Arretez-vous ici, s il vous plait.',
    'how much is this?': 'Combien ca coute ?',
    'can i pay by card?': 'Puis-je payer par carte ?',
    'where is the nearest station?': 'Ou est la gare la plus proche ?',
    'can you show me on the map?': 'Pouvez-vous me montrer sur la carte ?',
    'i need medical help.': 'J ai besoin d aide medicale.',
    'please call emergency services.': 'Appelez les urgences, s il vous plait.',
  },
  'es': {
    'hello, can you help me?': 'Hola, puede ayudarme?',
    'thank you very much.': 'Muchas gracias.',
    'where is the check-in desk?': 'Donde esta el mostrador de facturacion?',
    'is my flight on time?': 'Mi vuelo sale a tiempo?',
    'where is baggage claim?': 'Donde esta la recogida de equipaje?',
    'i have a reservation.': 'Tengo una reserva.',
    'can i check in early?': 'Puedo registrarme temprano?',
    'what time is check-out?': 'A que hora es la salida?',
    'a table for two, please.': 'Una mesa para dos, por favor.',
    'can i see the menu?': 'Puedo ver el menu?',
    'i have a food allergy.': 'Tengo una alergia alimentaria.',
    'please take me to this address.': 'Lleveme a esta direccion, por favor.',
    'how much will it cost?': 'Cuanto costara?',
    'please stop here.': 'Pare aqui, por favor.',
    'how much is this?': 'Cuanto cuesta esto?',
    'can i pay by card?': 'Puedo pagar con tarjeta?',
    'where is the nearest station?': 'Donde esta la estacion mas cercana?',
    'can you show me on the map?': 'Puede mostrarmelo en el mapa?',
    'i need medical help.': 'Necesito ayuda medica.',
    'please call emergency services.': 'Llame a emergencias, por favor.',
  },
  'it': {
    'hello, can you help me?': 'Ciao, puo aiutarmi?',
    'thank you very much.': 'Grazie mille.',
    'where is the check-in desk?': 'Dov e il banco del check-in?',
    'is my flight on time?': 'Il mio volo e in orario?',
    'where is baggage claim?': 'Dov e il ritiro bagagli?',
    'i have a reservation.': 'Ho una prenotazione.',
    'can i check in early?': 'Posso fare il check-in in anticipo?',
    'what time is check-out?': 'A che ora e il check-out?',
    'a table for two, please.': 'Un tavolo per due, per favore.',
    'can i see the menu?': 'Posso vedere il menu?',
    'i have a food allergy.': 'Ho un allergia alimentare.',
    'please take me to this address.':
        'Mi porti a questo indirizzo, per favore.',
    'how much will it cost?': 'Quanto costera?',
    'please stop here.': 'Si fermi qui, per favore.',
    'how much is this?': 'Quanto costa?',
    'can i pay by card?': 'Posso pagare con carta?',
    'where is the nearest station?': 'Dov e la stazione piu vicina?',
    'can you show me on the map?': 'Puo mostrarmelo sulla mappa?',
    'i need medical help.': 'Ho bisogno di assistenza medica.',
    'please call emergency services.':
        'Chiami i servizi di emergenza, per favore.',
  },
};
