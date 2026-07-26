import 'package:flutter/material.dart';

import '../../models/trip.dart';

class EditTripPage extends StatelessWidget {
  const EditTripPage({
    super.key,
    required this.tripId,
    this.initialTrip,
  });

  final String tripId;
  final Trip? initialTrip;

  @override
  Widget build(BuildContext context) {
    final title = initialTrip?.destination ?? tripId;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Trip')),
      body: Center(
        child: Text('EditTripPage placeholder for $title'),
      ),
    );
  }
}
