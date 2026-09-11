import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';

class TripDataScope {
  const TripDataScope({
    required this.tripId,
    required this.ownerUserId,
    required this.isShared,
    this.role,
  });

  final String tripId;
  final String ownerUserId;
  final bool isShared;
  final String? role;
}

final tripDataScopeProvider =
    FutureProvider.family<TripDataScope?, String>((ref, tripId) async {
  final user = ref.watch(immediateCurrentUserProvider);
  if (user == null) {
    return null;
  }

  final firestore = FirebaseFirestore.instance;
  final ownTrip = await firestore
      .collection('users')
      .doc(user.uid)
      .collection('trips')
      .doc(tripId)
      .get();
  if (ownTrip.exists) {
    return TripDataScope(
      tripId: tripId,
      ownerUserId: user.uid,
      isShared: false,
    );
  }

  final sharedTrip = await firestore
      .collection('users')
      .doc(user.uid)
      .collection('sharedTrips')
      .doc(tripId)
      .get();
  if (!sharedTrip.exists) {
    return TripDataScope(
      tripId: tripId,
      ownerUserId: user.uid,
      isShared: false,
    );
  }

  final data = sharedTrip.data() ?? const <String, dynamic>{};
  final ownerUserId = data['ownerUserId'] as String?;
  if (ownerUserId == null || ownerUserId.isEmpty) {
    return null;
  }
  return TripDataScope(
    tripId: tripId,
    ownerUserId: ownerUserId,
    isShared: true,
    role: data['role'] as String?,
  );
});
