import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/booking.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class ConfirmedBookingDetailsPage extends StatelessWidget {
  final Booking booking;

  const ConfirmedBookingDetailsPage({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(name: booking.currency);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('${booking.type.name.toUpperCase()} ${context.ui('details')}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(booking: booking),
            const SizedBox(height: 32),
            _Section(
              title: 'Booking Information',
              children: [
                _DetailRow(label: 'Booking ID', value: booking.id),
                _DetailRow(label: context.ui('status'), value: booking.status.name.toUpperCase(), isStatus: true),
                _DetailRow(label: 'Booked on', value: dateFormat.format(booking.createdAt)),
                _DetailRow(label: 'Total Paid', value: currencyFormat.format(booking.amount), isPrice: true),
              ],
            ),
            const SizedBox(height: 24),
            _getTypeSpecificDetails(context),
            const SizedBox(height: 48),
            Center(
              child: Text(
                'A confirmation email has been sent to your registered address.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getTypeSpecificDetails(BuildContext context) {
    switch (booking.type) {
      case BookingType.flight:
        return _Section(
          title: 'Flight Details',
          children: [
            _DetailRow(label: 'Airline', value: booking.metadata['airline'] ?? 'N/A'),
            _DetailRow(label: 'Flight Number', value: booking.metadata['flightNumber'] ?? 'N/A'),
            _DetailRow(label: 'Departure', value: booking.metadata['departure'] ?? 'N/A'),
            _DetailRow(label: 'Arrival', value: booking.metadata['arrival'] ?? 'N/A'),
          ],
        );
      case BookingType.hotel:
        return _Section(
          title: 'Hotel Details',
          children: [
            _DetailRow(label: 'Hotel Name', value: booking.metadata['hotelName'] ?? 'N/A'),
            _DetailRow(label: 'City', value: booking.metadata['city'] ?? 'N/A'),
            _DetailRow(label: 'Room Type', value: booking.metadata['roomType'] ?? 'N/A'),
          ],
        );
      case BookingType.transport:
        return _Section(
          title: 'Transport Details',
          children: [
            _DetailRow(label: 'Service', value: booking.metadata['providerName'] ?? 'N/A'),
            _DetailRow(label: context.ui('pickup'), value: booking.metadata['pickup'] ?? 'N/A'),
            _DetailRow(label: context.ui('destination'), value: booking.metadata['destination'] ?? 'N/A'),
          ],
        );
    }
  }
}

class _Header extends StatelessWidget {
  final Booking booking;

  const _Header({required this.booking});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String title;
    switch (booking.type) {
      case BookingType.flight:
        icon = Icons.flight_takeoff;
        title = booking.metadata['airline'] ?? 'Flight';
        break;
      case BookingType.hotel:
        icon = Icons.hotel;
        title = booking.metadata['hotelName'] ?? 'Hotel';
        break;
      case BookingType.transport:
        icon = Icons.local_taxi;
        title = booking.metadata['providerName'] ?? 'Transport';
        break;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                booking.type.name.toUpperCase(),
                style: const TextStyle(color: Colors.grey, letterSpacing: 1.1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isStatus;
  final bool isPrice;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isStatus = false,
    this.isPrice = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isStatus
                  ? Colors.green
                  : isPrice
                      ? Colors.green[700]
                      : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
