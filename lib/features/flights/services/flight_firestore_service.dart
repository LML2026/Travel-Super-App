import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/recent_search.dart';
import '../models/saved_flight.dart';

class FlightFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Save a recent flight search
  Future<void> saveRecentSearch({
    required String from,
    required String to,
    required String departureDate,
    String? returnDate,
    required int passengers,
    required String cabinClass,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    final recentSearch = RecentSearch(
      id: _firestore.collection('dummy').doc().id, // Generate doc ID
      from: from,
      to: to,
      departureDate: departureDate,
      returnDate: returnDate,
      passengers: passengers,
      cabinClass: cabinClass,
      searchedAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('recent_flight_searches')
        .doc(recentSearch.id)
        .set(recentSearch.toJson());
  }

  /// Get recent flight searches for current user
  Stream<List<RecentSearch>> getRecentSearches() {
    final userId = _userId;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('recent_flight_searches')
        .orderBy('searchedAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RecentSearch.fromJson({...doc.data(), 'id': doc.id}))
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
        .collection('recent_flight_searches')
        .doc(searchId)
        .delete();
  }

  /// Save a flight
  Future<void> saveFlight({
    required String flightId,
    required String airline,
    required String airlineLogo,
    required String flightNumber,
    required String origin,
    required String destination,
    required String departureAt,
    required String arrivalAt,
    required String duration,
    required int stops,
    required double amount,
    required String currency,
    required String cabinClass,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    final savedFlight = SavedFlight(
      id: _firestore.collection('dummy').doc().id,
      flightId: flightId,
      airline: airline,
      airlineLogo: airlineLogo,
      flightNumber: flightNumber,
      origin: origin,
      destination: destination,
      departureAt: departureAt,
      arrivalAt: arrivalAt,
      duration: duration,
      stops: stops,
      amount: amount,
      currency: currency,
      cabinClass: cabinClass,
      savedAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_flights')
        .doc(savedFlight.id)
        .set(savedFlight.toJson());
  }

  /// Get saved flights for current user
  Stream<List<SavedFlight>> getSavedFlights() {
    final userId = _userId;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_flights')
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SavedFlight.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// Check if a flight is saved
  Future<bool> isFlightSaved(String flightId) async {
    final userId = _userId;
    if (userId == null) return false;

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_flights')
        .where('flightId', isEqualTo: flightId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  /// Get save ID if flight is saved
  Future<String?> getSavedFlightId(String flightId) async {
    final userId = _userId;
    if (userId == null) return null;

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_flights')
        .where('flightId', isEqualTo: flightId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty ? snapshot.docs.first.id : null;
  }

  /// Remove a saved flight
  Future<void> removeSavedFlight(String saveId) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_flights')
        .doc(saveId)
        .delete();
  }
}
