import 'dart:js_interop';

@JS('itarevoPickPlace')
external JSPromise<JSString> _itarevoPickPlace();

Future<String?> pickPlaceJson() async {
  final result = await _itarevoPickPlace().toDart;
  final value = result.toDart;

  if (value.isEmpty) return null;

  return value;
}
