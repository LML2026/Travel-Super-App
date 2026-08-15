import 'timezone_resolution.dart';

abstract interface class TimezoneResolver {
  Future<TimezoneResolution> resolve(TimezoneCoordinateEvidence coordinates);
}
