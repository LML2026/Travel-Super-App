import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../providers/ai_assistant_provider.dart';
import '../widgets/assistant_message_bubble.dart';
import '../domain/ai_companion_actions.dart';
import '../../trips/domain/entities/trip.dart';
import '../../../app/app_routes.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class AiAssistantPage extends ConsumerStatefulWidget {
  const AiAssistantPage({super.key, this.trip, this.initialPrompt});

  final Trip? trip;
  final String? initialPrompt;

  @override
  ConsumerState<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends ConsumerState<AiAssistantPage> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final prompt = widget.initialPrompt;
    if (prompt != null && prompt.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(aiAssistantMessagesProvider.notifier).sendPrompt(
              prompt,
              activeTrip: widget.trip,
            );
      });
    }
  }

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
    await ref.read(aiAssistantMessagesProvider.notifier).sendPrompt(
          prompt,
          activeTrip: widget.trip,
        );
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(aiAssistantMessagesProvider);
    final isLoading = ref.watch(aiAssistantLoadingProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.ui('aiAssistant'))),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                if (widget.trip != null) _TripQuickActions(trip: widget.trip!),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: messages.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) =>
                        AssistantMessageBubble(message: messages[index]),
                  ),
                ),
              ],
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
                    hint:
                        'I am travelling to Paris for four days with a budget of £1,500',
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

class _TripQuickActions extends ConsumerWidget {
  const _TripQuickActions({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = AiCompanionActionCatalog.forTrip(hasTrip: true);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      child: Row(
        children: [
          for (final action in actions)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ActionChip(
                avatar: Icon(_iconFor(action.type), size: 17),
                label: Text(action.label),
                onPressed: () async {
                  if (_openAction(context, action.type, trip)) {
                    return;
                  }
                  if (action.prompt.isNotEmpty) {
                    await ref
                        .read(aiAssistantMessagesProvider.notifier)
                        .sendPrompt(
                          action.prompt,
                          activeTrip: trip,
                        );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  bool _openAction(
    BuildContext context,
    AiCompanionActionType type,
    Trip trip,
  ) {
    switch (type) {
      case AiCompanionActionType.nearby:
        context.pushNearbyEssentials();
        return true;
      case AiCompanionActionType.weather:
        context.pushWeather();
        return true;
      case AiCompanionActionType.route:
        context.pushMaps();
        return true;
      case AiCompanionActionType.bookings:
        context.pushTripBookings(trip.id);
        return true;
      case AiCompanionActionType.readiness:
        context.pushTripReadiness(trip);
        return true;
      case AiCompanionActionType.translate:
        context.pushTranslator();
        return true;
      case AiCompanionActionType.today:
      case AiCompanionActionType.next:
      case AiCompanionActionType.budget:
      case AiCompanionActionType.planTomorrow:
        return false;
    }
  }

  IconData _iconFor(AiCompanionActionType type) {
    switch (type) {
      case AiCompanionActionType.today:
        return Icons.today;
      case AiCompanionActionType.next:
        return Icons.arrow_forward;
      case AiCompanionActionType.nearby:
        return Icons.place_outlined;
      case AiCompanionActionType.weather:
        return Icons.cloud_outlined;
      case AiCompanionActionType.route:
        return Icons.directions_outlined;
      case AiCompanionActionType.bookings:
        return Icons.confirmation_num_outlined;
      case AiCompanionActionType.budget:
        return Icons.account_balance_wallet_outlined;
      case AiCompanionActionType.readiness:
        return Icons.checklist;
      case AiCompanionActionType.translate:
        return Icons.translate;
      case AiCompanionActionType.planTomorrow:
        return Icons.event_available;
    }
  }
}
