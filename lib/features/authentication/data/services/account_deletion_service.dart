import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/services/storage_service.dart';

abstract interface class AccountDeletionService {
  Future<void> deleteAccount({String? password});
}

class AccountDeletionException implements Exception {
  const AccountDeletionException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => message;
}

/// Deletes data owned directly by a Firebase user before deleting Auth.
///
/// Trip documents stored under another user's trip remain owned by that user;
/// this client cannot safely remove shared records it does not own.
class FirebaseAccountDeletionService implements AccountDeletionService {
  FirebaseAccountDeletionService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    StorageService? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? StorageService();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final StorageService _storage;

  static const _tripSubcollections = <String>[
    'activities',
    'aiPlannerPlans',
    'bookings',
    'collaborators',
    'documents',
    'expenses',
    'readinessItems',
    'reminders',
    'transport',
  ];

  @override
  Future<void> deleteAccount({String? password}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AccountDeletionException(
        'signed-out',
        'Please sign in again before deleting your account.',
      );
    }

    await _reauthenticate(user, password: password);
    await _deleteUserData(user.uid);

    try {
      await user.delete();
      await _auth.signOut();
      await _clearLocalUserData();
    } on FirebaseAuthException catch (error) {
      throw _mapAuthError(error);
    }
  }

  Future<void> _clearLocalUserData() async {
    await Future.wait([
      _storage.delete('itarevo_saved_items_v1'),
      _storage.delete('itarevo_translator_history_v1'),
    ]);
  }

  Future<void> _reauthenticate(User user, {String? password}) async {
    final providers = user.providerData.map((provider) => provider.providerId);

    try {
      if (providers.contains('password')) {
        final email = user.email;
        if (email == null || password == null || password.isEmpty) {
          throw const AccountDeletionException(
            'reauthentication-required',
            'Enter your current password to delete your account.',
          );
        }
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: email, password: password),
        );
        return;
      }

      if (providers.contains('google.com')) {
        final provider = GoogleAuthProvider();
        if (kIsWeb) {
          await user.reauthenticateWithPopup(provider);
        } else {
          await user.reauthenticateWithProvider(provider);
        }
        return;
      }

      if (providers.contains('apple.com')) {
        final provider = OAuthProvider('apple.com');
        if (kIsWeb) {
          await user.reauthenticateWithPopup(provider);
        } else {
          await user.reauthenticateWithProvider(provider);
        }
      }
    } on AccountDeletionException {
      rethrow;
    } on FirebaseAuthException catch (error) {
      throw _mapAuthError(error);
    }
  }

  Future<void> _deleteUserData(String uid) async {
    final userRef = _firestore.collection('users').doc(uid);

    final trips = await userRef.collection('trips').get();
    for (final trip in trips.docs) {
      for (final subcollection in _tripSubcollections) {
        await _deleteQuery(trip.reference.collection(subcollection));
      }
      await _deleteReferences(<DocumentReference<Map<String, dynamic>>>[
        trip.reference,
      ]);
    }

    for (final collection in <String>[
      'recent_flight_searches',
      'saved_flights',
      'recent_hotel_searches',
      'saved_hotels',
      'savedItems',
      'sharedTrips',
    ]) {
      await _deleteQuery(userRef.collection(collection));
    }

    final wallets = await userRef.collection('wallets').get();
    for (final wallet in wallets.docs) {
      await _deleteQuery(wallet.reference.collection('transactions'));
      await _deleteReferences(<DocumentReference<Map<String, dynamic>>>[
        wallet.reference,
      ]);
    }

    await _deleteReferences(<DocumentReference<Map<String, dynamic>>>[
      userRef,
    ]);
  }

  Future<void> _deleteQuery(
    Query<Map<String, dynamic>> query,
  ) async {
    final snapshot = await query.get();
    await _deleteReferences(snapshot.docs.map((doc) => doc.reference));
  }

  Future<void> _deleteReferences(
    Iterable<DocumentReference<Map<String, dynamic>>> references,
  ) async {
    var batch = _firestore.batch();
    var count = 0;
    for (final reference in references) {
      batch.delete(reference);
      count++;
      if (count == 400) {
        await batch.commit();
        batch = _firestore.batch();
        count = 0;
      }
    }
    if (count > 0) {
      await batch.commit();
    }
  }

  AccountDeletionException _mapAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'requires-recent-login':
        return const AccountDeletionException(
          'requires-recent-login',
          'For your security, sign in again before deleting your account.',
        );
      case 'wrong-password':
      case 'invalid-credential':
        return const AccountDeletionException(
          'invalid-credential',
          'The password was not accepted. Please try again.',
        );
      default:
        return const AccountDeletionException(
          'delete-failed',
          'We could not delete your account. Please try again later.',
        );
    }
  }
}
