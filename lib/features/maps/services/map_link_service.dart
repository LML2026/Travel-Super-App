class MapLinkService {
  const MapLinkService();

  Uri searchUri(String query) {
    return Uri.https('www.google.com', '/maps/search/', <String, String>{
      'api': '1',
      'query': query,
    });
  }

  Uri directionsUri({
    required String origin,
    required String destination,
    String travelMode = 'driving',
  }) {
    return Uri.https('www.google.com', '/maps/dir/', <String, String>{
      'api': '1',
      'origin': origin,
      'destination': destination,
      'travelmode': travelMode,
    });
  }
}