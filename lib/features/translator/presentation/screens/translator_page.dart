import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/translation_service.dart';
import '../../domain/translation_models.dart';
import '../providers/translator_provider.dart';

class TranslatorPage extends ConsumerStatefulWidget {
  const TranslatorPage({
    super.key,
    this.context,
  });

  final TranslatorContext? context;

  @override
  ConsumerState<TranslatorPage> createState() => _TranslatorPageState();
}

class _TranslatorPageState extends ConsumerState<TranslatorPage> {
  final _textController = TextEditingController();
  final _travellerController = TextEditingController();
  final _localController = TextEditingController();
  bool _contextApplied = false;

  @override
  void dispose() {
    _textController.dispose();
    _travellerController.dispose();
    _localController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translatorAsync = ref.watch(translatorControllerProvider);

    if (!_contextApplied && widget.context != null) {
      _contextApplied = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ref
            .read(translatorControllerProvider.notifier)
            .applyContext(widget.context!);
        final text = widget.context!.initialText;
        if (text?.trim().isNotEmpty == true) {
          _textController.text = text!.trim();
        }
      });
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Translator'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.translate_outlined), text: 'Translate'),
              Tab(icon: Icon(Icons.forum_outlined), text: 'Conversation'),
              Tab(icon: Icon(Icons.menu_book_outlined), text: 'Phrasebook'),
              Tab(icon: Icon(Icons.favorite_border), text: 'Saved'),
            ],
          ),
        ),
        body: translatorAsync.when(
          loading: () {
            final previous = translatorAsync.valueOrNull;
            if (previous == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return _TranslatorBody(
              state: previous,
              busy: true,
              textController: _textController,
              travellerController: _travellerController,
              localController: _localController,
            );
          },
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Translator unavailable: $error'),
            ),
          ),
          data: (state) => _TranslatorBody(
            state: state,
            busy: false,
            textController: _textController,
            travellerController: _travellerController,
            localController: _localController,
          ),
        ),
      ),
    );
  }
}

class _TranslatorBody extends ConsumerWidget {
  const _TranslatorBody({
    required this.state,
    required this.busy,
    required this.textController,
    required this.travellerController,
    required this.localController,
  });

  final TranslatorState state;
  final bool busy;
  final TextEditingController textController;
  final TextEditingController travellerController;
  final TextEditingController localController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TabBarView(
      children: [
        _TranslateTab(
          state: state,
          busy: busy,
          controller: textController,
        ),
        _ConversationTab(
          state: state,
          busy: busy,
          travellerController: travellerController,
          localController: localController,
        ),
        _PhrasebookTab(state: state, busy: busy),
        _HistoryTab(state: state),
      ],
    );
  }
}

class _TranslateTab extends ConsumerWidget {
  const _TranslateTab({
    required this.state,
    required this.busy,
    required this.controller,
  });

  final TranslatorState state;
  final bool busy;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final response = state.lastResponse;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ContextBanner(contextInfo: state.context),
        const SizedBox(height: 12),
        _LanguageRow(
          sourceCode: state.sourceLanguageCode,
          targetCode: state.targetLanguageCode,
          allowAutoDetect: true,
          onSourceChanged:
              ref.read(translatorControllerProvider.notifier).setSourceLanguage,
          onTargetChanged:
              ref.read(translatorControllerProvider.notifier).setTargetLanguage,
          onSwap: ref.read(translatorControllerProvider.notifier).swapLanguages,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          minLines: 4,
          maxLines: 7,
          textInputAction: TextInputAction.newline,
          decoration: const InputDecoration(
            labelText: 'Text to translate',
            hintText: 'Type a phrase for a hotel desk, restaurant or taxi...',
            border: OutlineInputBorder(),
          ),
          onChanged:
              ref.read(translatorControllerProvider.notifier).setInputText,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: busy
                  ? null
                  : () async {
                      ref
                          .read(translatorControllerProvider.notifier)
                          .setInputText(controller.text);
                      await ref
                          .read(translatorControllerProvider.notifier)
                          .translate();
                    },
              icon: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.translate),
              label: const Text('Translate'),
            ),
            OutlinedButton.icon(
              onPressed: response == null
                  ? null
                  : () => ref
                      .read(translatorControllerProvider.notifier)
                      .favouriteLatest(),
              icon: const Icon(Icons.favorite_border),
              label: const Text('Favourite'),
            ),
            OutlinedButton.icon(
              onPressed: response == null
                  ? null
                  : () async {
                      await Clipboard.setData(
                        ClipboardData(text: response.translatedText),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Translation copied.')),
                      );
                    },
              icon: const Icon(Icons.copy),
              label: const Text('Copy'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                controller.clear();
                ref.read(translatorControllerProvider.notifier).clearText();
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear'),
            ),
          ],
        ),
        if (state.errorMessage != null) ...[
          const SizedBox(height: 12),
          _ErrorPanel(message: state.errorMessage!),
        ],
        const SizedBox(height: 16),
        _TranslationResultCard(response: response),
      ],
    );
  }
}

class _ConversationTab extends ConsumerWidget {
  const _ConversationTab({
    required this.state,
    required this.busy,
    required this.travellerController,
    required this.localController,
  });

  final TranslatorState state;
  final bool busy;
  final TextEditingController travellerController;
  final TextEditingController localController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(translatorControllerProvider.notifier);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ConversationLanguageCard(state: state),
        const SizedBox(height: 12),
        _ConversationInput(
          title: 'Traveller',
          languageCode: state.travellerLanguageCode,
          controller: travellerController,
          busy: busy,
          onSend: () async {
            await notifier.addConversationTurn(
              text: travellerController.text,
              travellerSpeaking: true,
            );
            travellerController.clear();
          },
        ),
        const SizedBox(height: 12),
        _ConversationInput(
          title: 'Local',
          languageCode: state.localLanguageCode,
          controller: localController,
          busy: busy,
          onSend: () async {
            await notifier.addConversationTurn(
              text: localController.text,
              travellerSpeaking: false,
            );
            localController.clear();
          },
        ),
        const SizedBox(height: 16),
        if (state.conversation.isEmpty)
          const _EmptyPanel(
            icon: Icons.forum_outlined,
            title: 'Conversation mode',
            message:
                'Alternate between traveller and local messages. Large translated cards are designed to show across a counter or table.',
          )
        else
          for (final turn in state.conversation)
            _ConversationTurnCard(turn: turn),
      ],
    );
  }
}

class _PhrasebookTab extends ConsumerWidget {
  const _PhrasebookTab({
    required this.state,
    required this.busy,
  });

  final TranslatorState state;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = phrasebookPhrases
        .map((phrase) => phrase.category)
        .toSet()
        .toList(growable: false);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ContextBanner(contextInfo: state.context),
        const SizedBox(height: 12),
        Text(
          'Phrasebook',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap a phrase to translate it to ${languageNameFor(state.targetLanguageCode)}.',
        ),
        const SizedBox(height: 12),
        for (final category in categories) ...[
          Text(
            category,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          for (final phrase
              in phrasebookPhrases.where((item) => item.category == category))
            Card(
              child: ListTile(
                title: Text(phrase.text),
                trailing: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.translate),
                onTap: busy
                    ? null
                    : () => ref
                        .read(translatorControllerProvider.notifier)
                        .translatePhrase(phrase),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab({required this.state});

  final TranslatorState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favourites = state.favourites;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Favourites',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            TextButton.icon(
              onPressed: state.history.isEmpty
                  ? null
                  : ref
                      .read(translatorControllerProvider.notifier)
                      .clearHistory,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear recents'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (favourites.isEmpty)
          const _EmptyPanel(
            icon: Icons.favorite_border,
            title: 'No favourites yet',
            message: 'Favourite useful translations for quick access.',
          )
        else
          for (final item in favourites) _SavedTranslationTile(item: item),
        const SizedBox(height: 18),
        Text(
          'Recent translations',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        if (state.history.isEmpty)
          const _EmptyPanel(
            icon: Icons.history,
            title: 'No recent translations',
            message: 'Translations you make on this device will appear here.',
          )
        else
          for (final item in state.history) _SavedTranslationTile(item: item),
      ],
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.sourceCode,
    required this.targetCode,
    required this.allowAutoDetect,
    required this.onSourceChanged,
    required this.onTargetChanged,
    required this.onSwap,
  });

  final String sourceCode;
  final String targetCode;
  final bool allowAutoDetect;
  final ValueChanged<String> onSourceChanged;
  final ValueChanged<String> onTargetChanged;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final sourceLanguages = allowAutoDetect
        ? travelLanguages
        : travelLanguages.where((language) => language.code != 'auto').toList();
    final targetLanguages =
        travelLanguages.where((language) => language.code != 'auto').toList();
    return Row(
      children: [
        Expanded(
          child: _LanguageDropdown(
            label: 'From',
            value: sourceCode,
            languages: sourceLanguages,
            onChanged: onSourceChanged,
          ),
        ),
        IconButton(
          tooltip: 'Swap languages',
          onPressed: onSwap,
          icon: const Icon(Icons.swap_horiz),
        ),
        Expanded(
          child: _LanguageDropdown(
            label: 'To',
            value: targetCode == 'auto' ? 'en' : targetCode,
            languages: targetLanguages,
            onChanged: onTargetChanged,
          ),
        ),
      ],
    );
  }
}

class _LanguageDropdown extends StatelessWidget {
  const _LanguageDropdown({
    required this.label,
    required this.value,
    required this.languages,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<TravelLanguage> languages;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: languages.any((language) => language.code == value)
          ? value
          : languages.first.code,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final language in languages)
          DropdownMenuItem(
            value: language.code,
            child: Text(language.name),
          ),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

class _TranslationResultCard extends StatelessWidget {
  const _TranslationResultCard({required this.response});

  final TranslationResponse? response;

  @override
  Widget build(BuildContext context) {
    if (response == null) {
      return const _EmptyPanel(
        icon: Icons.translate_outlined,
        title: 'Ready to translate',
        message:
            'Local demo translations work offline for common travel phrases.',
      );
    }

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
                    '${languageNameFor(response!.sourceLanguageCode)} to ${languageNameFor(response!.targetLanguageCode)}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (response!.isDemo)
                  const Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text('Demo'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              response!.translatedText,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            if (response!.detectedLanguageCode != null) ...[
              const SizedBox(height: 8),
              Text(
                'Detected: ${languageNameFor(response!.detectedLanguageCode!)}',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConversationLanguageCard extends ConsumerWidget {
  const _ConversationLanguageCard({required this.state});

  final TranslatorState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(translatorControllerProvider.notifier);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _LanguageRow(
              sourceCode: state.travellerLanguageCode,
              targetCode: state.localLanguageCode,
              allowAutoDetect: false,
              onSourceChanged: notifier.setTravellerLanguage,
              onTargetChanged: notifier.setLocalLanguage,
              onSwap: notifier.swapConversationLanguages,
            ),
            const SizedBox(height: 8),
            const Text(
                'Voice input/output can be added behind this interface later.'),
          ],
        ),
      ),
    );
  }
}

class _ConversationInput extends StatelessWidget {
  const _ConversationInput({
    required this.title,
    required this.languageCode,
    required this.controller,
    required this.busy,
    required this.onSend,
  });

  final String title;
  final String languageCode;
  final TextEditingController controller;
  final bool busy;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title speaks ${languageNameFor(languageCode)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Type message...',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: busy ? null : onSend,
              icon: const Icon(Icons.send),
              label: const Text('Translate Card'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTurnCard extends StatelessWidget {
  const _ConversationTurnCard({required this.turn});

  final ConversationTurn turn;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${turn.speakerLabel} · ${languageNameFor(turn.sourceLanguageCode)} to ${languageNameFor(turn.targetLanguageCode)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(turn.sourceText),
            const Divider(height: 22),
            SelectableText(
              turn.translatedText,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedTranslationTile extends ConsumerWidget {
  const _SavedTranslationTile({required this.item});

  final SavedTranslation item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text(item.translatedText),
        subtitle: Text(
          '${item.sourceText}\n${languageNameFor(item.sourceLanguageCode)} to ${languageNameFor(item.targetLanguageCode)} · ${DateFormat('dd MMM HH:mm').format(item.createdAt)}',
        ),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: item.isFavourite ? 'Remove favourite' : 'Favourite',
          icon: Icon(item.isFavourite ? Icons.favorite : Icons.favorite_border),
          onPressed: () => ref
              .read(translatorControllerProvider.notifier)
              .toggleFavourite(item.id),
        ),
      ),
    );
  }
}

class _ContextBanner extends StatelessWidget {
  const _ContextBanner({required this.contextInfo});

  final TranslatorContext? contextInfo;

  @override
  Widget build(BuildContext context) {
    if (contextInfo == null) {
      return const SizedBox.shrink();
    }
    final destination = contextInfo!.destination;
    final label = contextInfo!.contextLabel;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.luggage_outlined),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                [
                  if (label?.isNotEmpty == true) label!,
                  if (destination?.isNotEmpty == true) destination!,
                ].join(' · '),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(message),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, size: 42),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
