class SelectedPlace {
  const SelectedPlace({
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
  });

  final String name;
  final String address;
  final double? latitude;
  final double? longitude;
}
