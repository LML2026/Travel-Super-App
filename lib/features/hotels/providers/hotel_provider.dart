import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hotel.dart';
import '../models/hotel_search_request.dart';
import '../models/recent_hotel_search.dart';
import '../models/saved_hotel.dart';
import '../repositories/hotel_repository.dart';
import '../services/hotel_api_service.dart';
import '../services/hotel_firestore_service.dart';
import '../../../core/utils/result.dart';

// Hotel API Service provider
final hotelApiServiceProvider = Provider<HotelApiService>((ref) {
  return HotelApiService();
});

// Hotel Repository provider
final hotelRepositoryProvider = Provider<HotelRepository>((ref) {
  final service = ref.watch(hotelApiServiceProvider);
  return HotelRepository(service);
});

// Hotel Search provider with family parameter
final hotelSearchProvider =
    FutureProvider.family<List<Hotel>, HotelSearchRequest>(
        (ref, request) async {
  final repository = ref.watch(hotelRepositoryProvider);
  final result = await repository.searchHotels(request);

  return switch (result) {
    Success(:final data) => data,
    Failure(:final message) => throw Exception(message),
  };
});

// ── Firestore service provider ─────────────────────────────────────────────
final hotelFirestoreServiceProvider = Provider<HotelFirestoreService>(
  (ref) => HotelFirestoreService(),
);

// ── Recent Searches provider ───────────────────────────────────────────────
/// Stream of recent hotel searches ordered by newest first
final recentHotelSearchesProvider =
    StreamProvider<List<RecentHotelSearch>>((ref) {
  return ref.read(hotelFirestoreServiceProvider).getRecentSearches();
});

// ── Save Recent Search provider ────────────────────────────────────────────
/// Mutation provider to save a search
final saveRecentHotelSearchProvider =
    FutureProvider.family<void, HotelSearchRequest>((ref, request) async {
  await ref.read(hotelFirestoreServiceProvider).saveRecentSearch(
        city: request.city,
        checkInDate: request.checkInDate.toString().split(' ')[0],
        checkOutDate: request.checkOutDate.toString().split(' ')[0],
        guests: request.guests,
        rooms: request.rooms,
      );
  // Invalidate the recent searches stream to refetch
  ref.invalidate(recentHotelSearchesProvider);
});

// ── Delete Recent Search provider ──────────────────────────────────────────
/// Mutation provider to delete a recent search
final deleteRecentHotelSearchProvider =
    FutureProvider.family<void, String>((ref, searchId) async {
  await ref.read(hotelFirestoreServiceProvider).deleteRecentSearch(searchId);
  // Invalidate the recent searches stream to refetch
  ref.invalidate(recentHotelSearchesProvider);
});

// ── Saved Hotels provider ──────────────────────────────────────────────────
/// Stream of saved hotels ordered by newest first
final savedHotelsProvider = StreamProvider<List<SavedHotel>>((ref) {
  return ref.read(hotelFirestoreServiceProvider).getSavedHotels();
});

// ── Save Hotel provider ────────────────────────────────────────────────────
/// Mutation provider to save a hotel
final saveHotelProvider =
    FutureProvider.family<void, SavedHotel>((ref, savedHotel) async {
  await ref.read(hotelFirestoreServiceProvider).saveHotel(
        hotelId: savedHotel.hotelId,
        name: savedHotel.name,
        city: savedHotel.city,
        country: savedHotel.country,
        address: savedHotel.address,
        currency: savedHotel.currency,
        rating: savedHotel.rating,
        pricePerNight: savedHotel.pricePerNight,
        totalPrice: savedHotel.totalPrice,
        beds: savedHotel.beds,
        roomType: savedHotel.roomType,
        amenities: savedHotel.amenities,
        freeCancellation: savedHotel.freeCancellation,
        description: savedHotel.description,
        image: savedHotel.image,
        nights: savedHotel.nights,
      );
  // Invalidate the saved hotels stream to refetch
  ref.invalidate(savedHotelsProvider);
});

// ── Remove Saved Hotel provider ────────────────────────────────────────────
/// Mutation provider to remove a saved hotel
final removeSavedHotelProvider =
    FutureProvider.family<void, String>((ref, saveId) async {
  await ref.read(hotelFirestoreServiceProvider).removeSavedHotel(saveId);
  // Invalidate the saved hotels stream to refetch
  ref.invalidate(savedHotelsProvider);
});

// ── Check if Hotel is Saved provider ───────────────────────────────────────
/// Check if a specific hotel is saved
final isHotelSavedProvider =
    FutureProvider.family<bool, String>((ref, hotelId) async {
  return ref.read(hotelFirestoreServiceProvider).isHotelSaved(hotelId);
});

// ── Get Save ID provider ───────────────────────────────────────────────────
/// Get the save document ID for a hotel
final getSavedHotelIdProvider =
    FutureProvider.family<String?, String>((ref, hotelId) async {
  return ref.read(hotelFirestoreServiceProvider).getSavedHotelId(hotelId);
});
