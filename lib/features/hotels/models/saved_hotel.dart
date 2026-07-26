class SavedHotel {
  final String id;
  final String hotelId;
  final String name;
  final String city;
  final double rating;
  final double pricePerNight;
  final double totalPrice;
  final int beds;
  final String image;
  final int nights;
  final DateTime savedAt;

  const SavedHotel({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.city,
    required this.rating,
    required this.pricePerNight,
    required this.totalPrice,
    required this.beds,
    required this.image,
    required this.nights,
    required this.savedAt,
  });

  factory SavedHotel.fromJson(Map<String, dynamic> json) {
    return SavedHotel(
      id: json['id'] as String? ?? '',
      hotelId: json['hotelId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0.0,
      pricePerNight: double.tryParse(json['pricePerNight']?.toString() ?? '') ?? 0.0,
      totalPrice: double.tryParse(json['totalPrice']?.toString() ?? '') ?? 0.0,
      beds: json['beds'] as int? ?? 1,
      image: json['image'] as String? ?? '🏨',
      nights: json['nights'] as int? ?? 1,
      savedAt: json['savedAt'] != null
          ? DateTime.parse(json['savedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'hotelId': hotelId,
    'name': name,
    'city': city,
    'rating': rating,
    'pricePerNight': pricePerNight,
    'totalPrice': totalPrice,
    'beds': beds,
    'image': image,
    'nights': nights,
    'savedAt': savedAt.toIso8601String(),
  };
}
