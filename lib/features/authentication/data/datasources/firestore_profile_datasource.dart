import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile_model.dart';

class FirestoreProfileDataSource {
  FirestoreProfileDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> ensureProfile({
    required String uid,
    required UserProfileModel profile,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);
    final snapshot = await userRef.get();
    final data = snapshot.data();
    final existingProfile = data?['profile'];
    final hasCreatedAt = existingProfile is Map<String, dynamic> &&
        existingProfile['createdAt'] != null;

    final payload = <String, dynamic>{
      'profile.displayName': profile.displayName,
      'profile.email': profile.email,
      'profile.photoUrl': profile.photoUrl,
      'profile.homeCountry': profile.homeCountry,
      'profile.homeCurrency': profile.homeCurrency,
      'profile.preferredLanguage': profile.preferredLanguage,
      'profile.updatedAt': FieldValue.serverTimestamp(),
    };

    if (!hasCreatedAt) {
      payload['profile.createdAt'] = FieldValue.serverTimestamp();
    }

    await userRef.set(payload, SetOptions(merge: true));
  }
}
