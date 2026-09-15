import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/booking.dart';
import '../../../features/flights/providers/flight_provider.dart';
import '../../../features/hotels/providers/hotel_provider.dart';
import '../../../features/taxi/presentation/providers/taxi_hub_provider.dart';
import '../../utils/user_facing_error.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class BookingStatusPage extends ConsumerWidget {
  final BookingType type;

  const BookingStatusPage({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = _getBookingState(ref);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.ui('bookingStatus')),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: bookingState.when(
          data: (booking) {
            if (booking == null) {
              return Text(context.ui('noBookingInProgress'));
            }
            return _SuccessView(booking: booking);
          },
          loading: () => const _LoadingView(),
          error: (error, stack) => _ErrorView(
            error: UserFacingError.message(
              error,
              fallback: 'We could not save this booking plan. Please try again.',
            ),
          ),
        ),
      ),
    );
  }

  AsyncValue<Booking?> _getBookingState(WidgetRef ref) {
    switch (type) {
      case BookingType.flight:
        return ref.watch(flightBookingProvider);
      case BookingType.hotel:
        return ref.watch(hotelBookingProvider);
      case BookingType.transport:
        return ref.watch(transportBookingProvider);
    }
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 24),
        Text(
          'Processing your booking...',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(context.ui('waitConfirmProvider')),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  final Booking booking;

  const _SuccessView({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
          const SizedBox(height: 24),
          const Text(
            'Booking Plan Saved',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Your ${booking.type.name} details were saved to your trip. No payment or provider order was created.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Booking ID: ${booking.id}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              child: Text(context.ui('backToTrip')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 80),
          const SizedBox(height: 24),
          const Text(
            'Booking Failed',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              child: Text(context.ui('goBack')),
            ),
          ),
        ],
      ),
    );
  }
}
