import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/core/constants/api_config.dart';

void main() {
  test('defaults API base URL to local development backend', () {
    expect(apiBaseUrl, 'http://localhost:5000');
  });
}
