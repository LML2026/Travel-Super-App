import 'package:flutter_test/flutter_test.dart';

import 'package:travel_super_app/core/utils/user_facing_error.dart';

void main() {
  test('hides provider details from network errors', () {
    expect(
      UserFacingError.message(
        Exception('DioException: https://private.example/api token=secret'),
        fallback: 'Could not load results.',
      ),
      'You appear to be offline. Check your connection and try again.',
    );
  });

  test('maps authentication failures to a safe action', () {
    expect(
      UserFacingError.message(
          StateError('Authentication required to manage trip documents.')),
      'Please sign in to continue.',
    );
  });

  test('uses a safe feature fallback for unknown errors', () {
    expect(
      UserFacingError.message(Exception('provider response internals'),
          fallback: 'Try again later.'),
      'Try again later.',
    );
  });
}
