class Hotel {
  final String id;
  final String name;
  final String city;
  final double rating;
  final double pricePerNight;
  final double totalPrice;
  final int beds;
  final String image;
  final int nights;

  const Hotel({
    required this.id,
    required this.name,
    required this.city,
    required this.rating,
    required this.pricePerNight,
    required this.totalPrice,
    required this.beds,
    required this.image,
    required this.nights,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0.0,
      pricePerNight: double.tryParse(json['pricePerNight']?.toString() ?? '') ?? 0.0,
      totalPrice: double.tryParse(json['totalPrice']?.toString() ?? '') ?? 0.0,
      beds: int.tryParse(json['beds']?.toString() ?? '') ?? 1,
      image: json['image']?.toString() ?? '🏨',
      nights: int.tryParse(json['nights']?.toString() ?? '') ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'rating': rating,
      'pricePerNight': pricePerNight,
      'totalPrice': totalPrice,
      'beds': beds,
      'image': image,
      'nights': nights,
    };
  }
}
