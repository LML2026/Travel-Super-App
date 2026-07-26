import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/recent_hotel_search.dart';
import '../models/saved_hotel.dart';

class HotelFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Save a recent hotel search
  Future<void> saveRecentSearch({
    required String city,
    required String checkInDate,
    required String checkOutDate,
    required int guests,
    required int rooms,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    final recentSearch = RecentHotelSearch(
      id: _firestore.collection('dummy').doc().id,
      city: city,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      guests: guests,
      rooms: rooms,
      searchedAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('recent_hotel_searches')
        .doc(recentSearch.id)
        .set(recentSearch.toJson());
  }

  /// Get recent hotel searches for current user
  Stream<List<RecentHotelSearch>> getRecentSearches() {
    final userId = _userId;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('recent_hotel_searches')
        .orderBy('searchedAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RecentHotelSearch.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// Delete a recent search
  Future<void> deleteRecentSearch(String searchId) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('recent_hotel_searches')
        .doc(searchId)
        .delete();
  }

  /// Save a hotel
  Future<void> saveHotel({
    required String hotelId,
    required String name,
    required String city,
    required double rating,
    required double pricePerNight,
    required double totalPrice,
    required int beds,
    required String image,
    required int nights,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    final savedHotel = SavedHotel(
      id: _firestore.collection('dummy').doc().id,
      hotelId: hotelId,
      name: name,
      city: city,
      rating: rating,
      pricePerNight: pricePerNight,
      totalPrice: totalPrice,
      beds: beds,
      image: image,
      nights: nights,
      savedAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_hotels')
        .doc(savedHotel.id)
        .set(savedHotel.toJson());
  }

  /// Get saved hotels for current user
  Stream<List<SavedHotel>> getSavedHotels() {
    final userId = _userId;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_hotels')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SavedHotel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// Check if a hotel is saved
  Future<bool> isHotelSaved(String hotelId) async {
    final userId = _userId;
    if (userId == null) return false;

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_hotels')
        .where('hotelId', isEqualTo: hotelId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  /// Get save ID if hotel is saved
  Future<String?> getSavedHotelId(String hotelId) async {
    final userId = _userId;
    if (userId == null) return null;

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_hotels')
        .where('hotelId', isEqualTo: hotelId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty ? snapshot.docs.first.id : null;
  }

  /// Remove a saved hotel
  Future<void> removeSavedHotel(String saveId) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_hotels')
        .doc(saveId)
        .delete();
  }
}
