class Destination {
  final String city;
  final String country;
  final String imageUrl;
  final String description;

  const Destination({
    required this.city,
    required this.country,
    required this.imageUrl,
    required this.description,
  });

  String get image => imageUrl;
}
