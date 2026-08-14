import 'dart:js_interop';

@JS('itarevoLoadGoogleMaps')
external JSPromise<JSBoolean> _loadGoogleMaps(JSString apiKey);

Future<bool> loadGoogleMaps(String apiKey) async {
  final loaded = await _loadGoogleMaps(apiKey.toJS).toDart;

  return loaded.toDart;
}
