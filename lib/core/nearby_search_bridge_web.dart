import 'dart:js_interop';

@JS('itarevoNearbySearch')
external JSPromise<JSString> _itarevoNearbySearch(
  JSNumber latitude,
  JSNumber longitude,
  JSString placeType,
);

@JS('window.open')
external void _openWindow(JSString url, JSString target, JSString features);

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

Future<bool> openDirectionsUrl(String url) async {
  _openWindow(url.toJS, '_blank'.toJS, 'noopener,noreferrer'.toJS);

  return true;
}
