import 'package:flutter/material.dart';

import 'dashboard_section.dart';

class HotelCard extends StatelessWidget {
  const HotelCard({
    super.key,
    this.name,
    this.address,
  });

  final String? name;
  final String? address;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      icon: Icons.hotel,
      title: 'Hotel',
      child: name == null
          ? const Text('No linked hotel yet.')
          : Column(
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
    );
  }
}
