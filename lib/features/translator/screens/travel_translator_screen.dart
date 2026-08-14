import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/translation/translation_language.dart';
import '../../../core/translation/translation_service.dart';
import '../../../l10n/app_localizations.dart';

class TravelTranslatorScreen extends StatefulWidget {
  final TranslationService service;

  const TravelTranslatorScreen({
    super.key,
    this.service = const UnavailableTranslationService(),
  });

  @override
  State<TravelTranslatorScreen> createState() => _TravelTranslatorScreenState();
}

class _TravelTranslatorScreenState extends State<TravelTranslatorScreen> {
  final _sourceController = TextEditingController();
  TranslationLanguage _sourceLanguage = TranslationLanguage.autoDetect;
  late TranslationLanguage _targetLanguage;
  String? _translatedText;
  String? _errorMessage;
  bool _isLoading = false;
  bool _hasInitializedTarget = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitializedTarget) {
      _targetLanguage = _targetLanguageOrDefault();
      _hasInitializedTarget = true;
    }
  }

  TranslationLanguage _targetLanguageOrDefault() {
    final appLocale = Localizations.localeOf(context);
    return TranslationLanguage.defaultTarget(appLocale);
  }

  @override
  void dispose() {
    _sourceController.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    final l10n = AppLocalizations.of(context);
    final sourceText = _sourceController.text.trim();

    setState(() {
      _errorMessage = null;
      _translatedText = null;
    });

    if (sourceText.isEmpty) {
      setState(() => _errorMessage = l10n.enterTextToTranslate);
      return;
    }

    if (!_sourceLanguage.isAutoDetect &&
        _sourceLanguage.code == _targetLanguage.code) {
      setState(() => _errorMessage = l10n.chooseDifferentLanguages);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await widget.service.translate(
        TranslationRequest(
          sourceText: sourceText,
          sourceLanguageCode: _sourceLanguage.code,
          targetLanguageCode: _targetLanguage.code,
        ),
      );

      if (!mounted) return;
      setState(() => _translatedText = result.translatedText);
    } on TranslationProviderUnavailable {
      if (!mounted) return;
      setState(() => _errorMessage = l10n.translationProviderUnavailable);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = l10n.translationFailed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _swapLanguages() {
    if (_sourceLanguage.isAutoDetect) {
      setState(() {
        _sourceLanguage = _targetLanguage;
        _targetLanguage = TranslationLanguage.supported.firstWhere(
          (language) => language.code != _sourceLanguage.code,
          orElse: () => TranslationLanguage.supported.first,
        );
        _translatedText = null;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      final previousSource = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = previousSource;
      _translatedText = null;
      _errorMessage = null;
    });
  }

  void _clear() {
    setState(() {
      _sourceController.clear();
      _translatedText = null;
      _errorMessage = null;
      _isLoading = false;
    });
  }

  Future<void> _copyTranslation() async {
    final translatedText = _translatedText;
    if (translatedText == null || translatedText.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: translatedText));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).translationCopied)),
    );
  }

  void _usePhrase(String phrase) {
    setState(() {
      _sourceController.text = phrase;
      _sourceController.selection = TextSelection.fromPosition(
        TextPosition(offset: phrase.length),
      );
      _translatedText = null;
      _errorMessage = null;
    });
  }

  TextDirection _directionFor(TranslationLanguage language) {
    return language.locale.languageCode == 'ar' ||
            language.locale.languageCode == 'fa'
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phrases = <({String label, String text})>[
      (label: l10n.phraseHello, text: 'Hello'),
      (label: l10n.phraseThankYou, text: 'Thank you'),
      (label: l10n.phrasePlease, text: 'Please'),
      (label: l10n.phraseBathroom, text: 'Where is the bathroom?'),
      (label: l10n.phraseCost, text: 'How much does this cost?'),
      (label: l10n.phraseHelp, text: 'I need help.'),
      (label: l10n.phraseTrain, text: 'Where is the train station?'),
      (label: l10n.phraseTaxi, text: 'Can you call a taxi?'),
      (label: l10n.phraseReservation, text: 'I have a reservation.'),
      (label: l10n.phraseDontUnderstand, text: "I don't understand."),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translatorTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text(
              l10n.translatorSubtitle,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _LanguageField(
                    label: l10n.sourceLanguage,
                    value: _sourceLanguage,
                    languages: [
                      TranslationLanguage.autoDetect,
                      ...TranslationLanguage.supported,
                    ],
                    onChanged: (language) {
                      if (language == null) return;
                      setState(() {
                        _sourceLanguage = language;
                        _translatedText = null;
                        _errorMessage = null;
                      });
                    },
                  ),
                ),
                IconButton(
                  tooltip: l10n.swapLanguages,
                  onPressed: _swapLanguages,
                  icon: const Icon(Icons.swap_horiz),
                ),
                Expanded(
                  child: _LanguageField(
                    label: l10n.targetLanguage,
                    value: _targetLanguage,
                    languages: TranslationLanguage.supported,
                    onChanged: (language) {
                      if (language == null) return;
                      setState(() {
                        _targetLanguage = language;
                        _translatedText = null;
                        _errorMessage = null;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _sourceController,
              minLines: 5,
              maxLines: 8,
              textDirection: _directionFor(_sourceLanguage),
              decoration: InputDecoration(
                labelText: l10n.sourceText,
                hintText: l10n.sourceTextHint,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _translate,
                    icon: _isLoading
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.translate),
                    label: Text(l10n.translate),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  tooltip: l10n.clear,
                  onPressed: _isLoading ? null : _clear,
                  icon: const Icon(Icons.clear),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _ResultPanel(
              translatedText: _translatedText,
              errorMessage: _errorMessage,
              isLoading: _isLoading,
              direction: _directionFor(_targetLanguage),
              onCopy: _copyTranslation,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.travelPhrases,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final phrase in phrases)
                  ActionChip(
                    label: Text(phrase.label),
                    onPressed: () => _usePhrase(phrase.text),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageField extends StatelessWidget {
  final String label;
  final TranslationLanguage value;
  final List<TranslationLanguage> languages;
  final ValueChanged<TranslationLanguage?> onChanged;

  const _LanguageField({
    required this.label,
    required this.value,
    required this.languages,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<TranslationLanguage>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final language in languages)
          DropdownMenuItem(
            value: language,
            child: Text(
              language.isAutoDetect
                  ? AppLocalizations.of(context).autoDetect
                  : language.nativeName,
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final String? translatedText;
  final String? errorMessage;
  final bool isLoading;
  final TextDirection direction;
  final VoidCallback onCopy;

  const _ResultPanel({
    required this.translatedText,
    required this.errorMessage,
    required this.isLoading,
    required this.direction,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.translationResult,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (translatedText != null)
                  IconButton(
                    tooltip: l10n.copyTranslation,
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy_outlined),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (isLoading)
              const LinearProgressIndicator()
            else if (errorMessage != null)
              Text(
                errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            else if (translatedText != null)
              Text(
                translatedText!,
                textDirection: direction,
                style: Theme.of(context).textTheme.bodyLarge,
              )
            else
              Text(l10n.translationResultHint),
          ],
        ),
      ),
    );
  }
}
