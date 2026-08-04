import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/ai_assistant_provider.dart';
import '../widgets/assistant_message_bubble.dart';

class AiAssistantPage extends ConsumerStatefulWidget {
  const AiAssistantPage({super.key});

  @override
  ConsumerState<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends ConsumerState<AiAssistantPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) {
      return;
    }
    _controller.clear();
    await ref.read(aiAssistantMessagesProvider.notifier).sendPrompt(prompt);
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(aiAssistantMessagesProvider);
    final isLoading = ref.watch(aiAssistantLoadingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                return AssistantMessageBubble(message: messages[index]);
              },
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: LinearProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _controller,
                    label: 'Ask the assistant',
                    hint: 'I am travelling to Paris for four days with a budget of £1,500',
                    prefixIcon: Icons.smart_toy_outlined,
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                PrimaryButton(
                  text: 'Send',
                  icon: Icons.send,
                  onPressed: isLoading ? () {} : _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
