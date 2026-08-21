import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/utils/user_facing_error.dart';
import '../../domain/entities/taxi_ride_request.dart';
import '../providers/taxi_hub_provider.dart';

class TaxiResultsPage extends ConsumerWidget {
  const TaxiResultsPage({
    required this.request,
    super.key,
  });

  final TaxiRideRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionsAsync = ref.watch(taxiRideOptionsProvider(request));

    return Scaffold(
      appBar: AppBar(title: const Text('Ride options')),
      body: optionsAsync.when(
        data: (options) {
          if (options.isEmpty) {
            return const Center(
              child: Text('No providers are currently available.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final option = options[index];

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              option.providerName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Chip(
                            label: Text(
                              '${option.currency} ${option.estimatedFare.toStringAsFixed(2)}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                          '${option.description}. Estimated option; no provider order has been placed.'),
                      const SizedBox(height: 8),
                      Text(
                          'Estimated pickup: ${option.estimatedPickupMinutes} min'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                context.pushTaxiBookingDetails(
                                  TaxiBookingRouteArgs(
                                    request: request,
                                    option: option,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Review planned ride'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(UserFacingError.message(
              error,
              fallback: 'Ride options are unavailable right now.',
            )),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
