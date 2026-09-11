import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/app/router.dart';

void main() {
  test('protects user-owned routes while leaving discovery public', () {
    expect(isProtectedPath('/trips/trip-1'), isTrue);
    expect(isProtectedPath('/bookings'), isTrue);
    expect(isProtectedPath('/profile'), isTrue);
    expect(isProtectedPath('/flights/saved'), isTrue);
    expect(isProtectedPath('/hotels/recent'), isTrue);
    expect(isProtectedPath('/live-trip'), isTrue);
    expect(isProtectedPath('/discover'), isFalse);
    expect(isProtectedPath('/flights/search'), isFalse);
    expect(isProtectedPath('/hotels'), isFalse);
  });
}
