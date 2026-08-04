import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/travel_card.dart';
import '../models/nearby_service_metadata.dart';
import '../models/nearby_service_type.dart';
import 'widgets/nearby_state_views.dart';

class NearbyEssentialsPage extends StatefulWidget {
  const NearbyEssentialsPage({
    this.initialService,
    super.key,
  });

  final NearbyServiceType? initialService;

  @override
  State<NearbyEssentialsPage> createState() => _NearbyEssentialsPageState();
}

class _NearbyEssentialsPageState extends State<NearbyEssentialsPage> {
  NearbyServiceType _selectedService = nearbyEssentialsMvpServices.first;

  @override
  void initState() {
    super.initState();
    _selectedService = widget.initialService ?? nearbyEssentialsMvpServices.first;
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_selectedService.metadata.label} live search is coming in the next nearby batch.',
        ),
      ),
    );
  }

  String _queryPreviewFor(NearbyServiceType serviceType) {
    switch (serviceType) {
      case NearbyServiceType.toilet:
        return 'public toilets open now within 500 m';
      case NearbyServiceType.atm:
        return 'atm open now within 1 km';
      case NearbyServiceType.pharmacy:
        return 'pharmacy open now within 1 km';
      case NearbyServiceType.hospital:
        return 'hospital open now within 3 km';
      case NearbyServiceType.restaurant:
        return 'restaurants open now within 2 km';
      case NearbyServiceType.cafe:
        return 'cafes open now within 2 km';
      case NearbyServiceType.fuel:
        return 'fuel stations open now within 5 km';
      case NearbyServiceType.parking:
        return 'parking open now within 2 km';
      case NearbyServiceType.supermarket:
        return 'supermarkets open now within 2 km';
      case NearbyServiceType.hotel:
        return 'hotels within 3 km';
      case NearbyServiceType.taxi:
        return 'taxi pickup points within 2 km';
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedMetadata = _selectedService.metadata;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Essentials'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          TravelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.place_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Practical stops for the moment you need them',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Nearby Essentials will bring toilets, ATMs, pharmacies, hospitals, food, and cafes into one travel-first utility hub.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  text: 'Open in maps',
                  icon: Icons.explore_outlined,
                  onPressed: _showComingSoon,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(
            title: 'Core services',
            subtitle: 'The first Nearby Essentials services planned for the MVP utility layer.',
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: nearbyEssentialsMvpServices.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.45,
            ),
            itemBuilder: (context, index) {
              final serviceType = nearbyEssentialsMvpServices[index];
              final metadata = serviceType.metadata;
              final isSelected = serviceType == _selectedService;

              return TravelCard(
                onTap: () {
                  setState(() {
                    _selectedService = serviceType;
                  });
                },
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          metadata.icon,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const Spacer(),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Selected',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      metadata.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      metadata.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(
            title: '${selectedMetadata.label} filters',
            subtitle: 'Reusable filter metadata is ready before live provider wiring.',
          ),
          const SizedBox(height: AppSpacing.md),
          TravelCard(
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: selectedMetadata.previewFilters
                  .map(
                    (filterLabel) => Chip(label: Text(filterLabel)),
                  )
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TravelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Maps handoff preview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _queryPreviewFor(_selectedService),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(
            title: '${selectedMetadata.label} results foundation',
            subtitle: 'This placeholder becomes the shared results area in the next commit.',
          ),
          const SizedBox(height: AppSpacing.md),
          NearbyPlaceholderState(
            title: 'Select ${selectedMetadata.label.toLowerCase()} near me',
            message:
                'The hub, service metadata, and filters are in place. Live results, maps handoff, and location-aware search are intentionally deferred to the next nearby commit.',
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(
            title: 'State foundations',
            subtitle: 'Loading, empty, and error states are ready for engine wiring.',
          ),
          const SizedBox(height: AppSpacing.md),
          const NearbyLoadingState(
            message: 'Preparing nearby essentials around your current stop...',
          ),
          const SizedBox(height: AppSpacing.md),
          const NearbyEmptyState(
            title: 'No nearby results yet',
            message: 'This shared empty state will be used when a service search returns no nearby essentials.',
          ),
          const SizedBox(height: AppSpacing.md),
          NearbyErrorState(
            title: 'Nearby Essentials unavailable',
            message: 'This shared error state is ready for provider, permission, or location failures.',
            onRetry: _showComingSoon,
          ),
        ],
      ),
    );
  }
}