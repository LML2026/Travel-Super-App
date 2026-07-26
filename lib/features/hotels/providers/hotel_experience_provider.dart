import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/currency_rate.dart';
import '../models/nearby_bundle.dart';
import '../services/hotel_experience_service.dart';

final hotelExperienceServiceProvider = Provider<HotelExperienceService>(
  (ref) => HotelExperienceService(),
);

final nearbyBundleProvider = FutureProvider.family<NearbyBundle, String>((ref, city) async {
  final service = ref.read(hotelExperienceServiceProvider);
  return service.getNearbyBundle(city);
});

final currencyRateProvider = FutureProvider.family<CurrencyRate, String>((ref, target) async {
  final service = ref.read(hotelExperienceServiceProvider);
  return service.getCurrencyRate(target: target);
});
