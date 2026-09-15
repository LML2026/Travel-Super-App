import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/authentication/domain/entities/auth_user.dart';
import 'package:travel_super_app/features/authentication/domain/repositories/authentication_repository.dart';
import 'package:travel_super_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:travel_super_app/features/flights/models/saved_flight.dart';
import 'package:travel_super_app/features/flights/providers/flight_provider.dart';
import 'package:travel_super_app/features/home/providers/dashboard_provider.dart';
import 'package:travel_super_app/features/hotels/models/saved_hotel.dart';
import 'package:travel_super_app/features/hotels/providers/hotel_provider.dart';
import 'package:travel_super_app/features/trips/domain/entities/trip.dart';
import 'package:travel_super_app/features/trips/domain/repositories/trip_repository.dart';
import 'package:travel_super_app/features/trips/presentation/providers/trip_provider.dart';

void main() {
  const anonymousUser = AuthUser(
    uid: 'anonymous-uid',
    email: null,
    emailVerified: false,
    isAnonymous: true,
  );
  const reviewUser = AuthUser(
    uid: 'review-uid',
    email: 'appreview@itarevo.com',
    emailVerified: true,
  );

  test('saved dashboard streams rebuild from anonymous UID to signed-in UID',
      () async {
    final authRepository = _FakeAuthenticationRepository(anonymousUser);
    final flightUserIds = <String>[];
    final hotelUserIds = <String>[];
    final container = ProviderContainer(
      overrides: [
        authenticationRepositoryProvider.overrideWithValue(authRepository),
        savedFlightsStreamForUserProvider.overrideWithValue((userId) {
          flightUserIds.add(userId);
          return Stream.value(const <SavedFlight>[]);
        }),
        savedHotelsStreamForUserProvider.overrideWithValue((userId) {
          hotelUserIds.add(userId);
          return Stream.value(const <SavedHotel>[]);
        }),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(authRepository.dispose);

    await container.read(savedFlightsProvider.future);
    await container.read(savedHotelsProvider.future);

    expect(flightUserIds, <String>['anonymous-uid']);
    expect(hotelUserIds, <String>['anonymous-uid']);

    authRepository.emit(reviewUser);
    await container.pump();

    await container.read(savedFlightsProvider.future);
    await container.read(savedHotelsProvider.future);

    expect(flightUserIds, <String>['anonymous-uid', 'review-uid']);
    expect(hotelUserIds, <String>['anonymous-uid', 'review-uid']);
  });

  test(
      'dashboard uses signed-in saved-flight and saved-hotel streams after auth transition',
      () async {
    final authRepository = _FakeAuthenticationRepository(anonymousUser);
    final flightUserIds = <String>[];
    final hotelUserIds = <String>[];
    final tripRepository = _FakeTripRepository([
      Trip(
        id: 'trip-review',
        title: 'Review trip',
        destination: 'London',
        startDate: DateTime.now().add(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 6)),
        budget: 1000,
      ),
    ]);
    final container = ProviderContainer(
      overrides: [
        authenticationRepositoryProvider.overrideWithValue(authRepository),
        tripRepositoryProvider.overrideWithValue(tripRepository),
        savedFlightsStreamForUserProvider.overrideWithValue((userId) {
          flightUserIds.add(userId);
          return Stream.value(const <SavedFlight>[]);
        }),
        savedHotelsStreamForUserProvider.overrideWithValue((userId) {
          hotelUserIds.add(userId);
          return Stream.value(const <SavedHotel>[]);
        }),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(authRepository.dispose);

    await container.read(savedFlightsProvider.future);
    await container.read(savedHotelsProvider.future);

    authRepository.emit(reviewUser);
    await container.pump();

    final summary = await container.read(dashboardSummaryProvider.future);

    expect(summary.hasUpcomingTrip, isTrue);
    expect(flightUserIds.last, 'review-uid');
    expect(hotelUserIds.last, 'review-uid');
  });
}

class _FakeAuthenticationRepository implements AuthenticationRepository {
  _FakeAuthenticationRepository(this.currentUser);

  final _controller = StreamController<AuthUser?>.broadcast();

  @override
  AuthUser? currentUser;

  void emit(AuthUser? user) {
    currentUser = user;
    _controller.add(user);
  }

  void dispose() {
    _controller.close();
  }

  @override
  Stream<AuthUser?> authStateChanges() => _controller.stream;

  @override
  Future<AuthUser?> signIn({
    required String email,
    required String password,
  }) async {
    return currentUser;
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return currentUser!;
  }

  @override
  Future<AuthUser?> signInWithApple() async => currentUser;

  @override
  Future<AuthUser?> signInWithGoogle() async => currentUser;

  @override
  Future<void> reloadCurrentUser() async {}

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> signOut() async {
    emit(null);
  }
}

class _FakeTripRepository implements TripRepository {
  const _FakeTripRepository(this.trips);

  final List<Trip> trips;

  @override
  Stream<List<Trip>> watchTrips() => Stream.value(trips);

  @override
  Future<List<Trip>> getAll() async => trips;

  @override
  Future<Trip?> get(String id) async {
    for (final trip in trips) {
      if (trip.id == id) {
        return trip;
      }
    }
    return null;
  }

  @override
  Future<void> createTrip(Trip trip) async {}

  @override
  Future<void> updateTrip(Trip trip) async {}

  @override
  Future<void> deleteTrip(String id) async {}
}
