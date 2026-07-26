import 'package:flutter/material.dart';

import 'dashboard_section.dart';

class HotelCard extends StatelessWidget {
  const HotelCard({
    super.key,
    this.name,
    this.address,
    this.onOpenHotels,
    this.onViewHotelDetails,
    this.onLinkHotel,
    this.onUnlinkHotel,
  });

  final String? name;
  final String? address;
  final VoidCallback? onOpenHotels;
  final VoidCallback? onViewHotelDetails;
  final VoidCallback? onLinkHotel;
  final VoidCallback? onUnlinkHotel;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      icon: Icons.hotel,
      title: 'Hotel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (name == null)
            const Text('No linked hotel yet.')
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (address != null && address!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(address!),
                ],
              ],
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(
                onPressed: onOpenHotels,
                child: const Text('Open Hotels'),
              ),
              if (name != null)
                OutlinedButton(
                  onPressed: onViewHotelDetails,
                  child: const Text('View Details'),
                ),
              if (name == null)
                FilledButton(
                  onPressed: onLinkHotel,
                  child: const Text('Link Hotel'),
                )
              else
                OutlinedButton(
                  onPressed: onUnlinkHotel,
                  child: const Text('Unlink'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
