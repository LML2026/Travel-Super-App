import 'dart:js_interop';

@JS('itarevoNearbySearch')
external JSPromise<JSString> _itarevoNearbySearch(
  JSNumber latitude,
  JSNumber longitude,
  JSString placeType,
);

Future<String> nearbySearchJson(
  double latitude,
  double longitude,
  String placeType,
) async {
  final result = await _itarevoNearbySearch(
    latitude.toJS,
    longitude.toJS,
    placeType.toJS,
  ).toDart;

  return result.toDart;
}
