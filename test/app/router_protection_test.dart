import 'package:travel_super_app/features/authentication/domain/entities/auth_user.dart';
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

  test('anonymous Firebase users remain guests for app routing', () {
    const anonymousUser = AuthUser(
      uid: 'anon-1',
      email: null,
      emailVerified: false,
      isAnonymous: true,
    );
    const signedInUser = AuthUser(
      uid: 'user-1',
      email: 'user@example.com',
      emailVerified: true,
    );

    expect(isSignedInAppUser(null), isFalse);
    expect(isSignedInAppUser(anonymousUser), isFalse);
    expect(isSignedInAppUser(signedInUser), isTrue);
  });
}
