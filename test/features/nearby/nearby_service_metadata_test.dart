import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/features/nearby/models/nearby_service_metadata.dart';
import 'package:travel_super_app/features/nearby/models/nearby_service_type.dart';

void main() {
  test('nearby service metadata exposes stable MVP services', () {
    expect(nearbyEssentialsMvpServices, const <NearbyServiceType>[
      NearbyServiceType.toilet,
      NearbyServiceType.atm,
      NearbyServiceType.pharmacy,
      NearbyServiceType.hospital,
      NearbyServiceType.restaurant,
      NearbyServiceType.cafe,
    ]);
  });

  test('toilet metadata exposes travel-first filter preview', () {
    final metadata = NearbyServiceType.toilet.metadata;

    expect(metadata.label, 'Toilets');
    expect(metadata.isMvp, isTrue);
    expect(metadata.previewFilters, contains('Open now'));
    expect(metadata.previewFilters, contains('Baby changing'));
    expect(metadata.previewFilters, contains('Within 500 m'));
  });

  test('all service types resolve metadata', () {
    for (final serviceType in NearbyServiceType.values) {
      expect(serviceType.metadata.label, isNotEmpty);
      expect(serviceType.metadata.description, isNotEmpty);
    }
  });
}
