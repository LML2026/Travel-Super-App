import 'dart:js_interop';

@JS('itarevoCalculateRoute')
external JSPromise<JSString> _calculateRoute(
  JSNumber originLatitude,
  JSNumber originLongitude,
  JSNumber destinationLatitude,
  JSNumber destinationLongitude,
  JSString travelMode,
);

Future<String?> calculateRouteJson(
  double originLatitude,
  double originLongitude,
  double destinationLatitude,
  double destinationLongitude,
  String travelMode,
) async {
  final result = await _calculateRoute(
    originLatitude.toJS,
    originLongitude.toJS,
    destinationLatitude.toJS,
    destinationLongitude.toJS,
    travelMode.toJS,
  ).toDart;
  final value = result.toDart;

  return value.isEmpty ? null : value;
}
