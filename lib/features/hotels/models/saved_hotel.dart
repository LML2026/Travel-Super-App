class SavedHotel {
  final String id;
  final String hotelId;
  final String name;
  final String city;
  final String country;
  final String address;
  final String currency;
  final double rating;
  final double pricePerNight;
  final double totalPrice;
  final int beds;
  final String roomType;
  final List<String> amenities;
  final bool freeCancellation;
  final String description;
  final String image;
  final int nights;
  final DateTime savedAt;

  const SavedHotel({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.city,
    this.country = '',
    this.address = '',
    this.currency = 'GBP',
    required this.rating,
    required this.pricePerNight,
    required this.totalPrice,
    required this.beds,
    this.roomType = 'Standard Room',
    this.amenities = const ['Free Wi-Fi', 'Breakfast Included'],
    this.freeCancellation = true,
    this.description = '',
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
      country: json['country'] as String? ?? '',
      address: json['address'] as String? ?? '',
      currency: json['currency'] as String? ?? 'GBP',
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0.0,
      pricePerNight: double.tryParse(
            json['pricePerNight']?.toString() ?? json['price']?.toString() ?? '',
          ) ??
          0.0,
      totalPrice: double.tryParse(json['totalPrice']?.toString() ?? '') ?? 0.0,
      beds: json['beds'] as int? ?? 1,
      roomType: json['roomType'] as String? ?? 'Standard Room',
      amenities: (json['amenities'] is List)
          ? List<String>.from((json['amenities'] as List).map((e) => e.toString()))
          : const ['Free Wi-Fi', 'Breakfast Included'],
      freeCancellation: json['freeCancellation'] == null
          ? true
          : json['freeCancellation'] == true,
      description: json['description'] as String? ?? '',
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
    'country': country,
    'address': address,
    'currency': currency,
    'rating': rating,
    'price': pricePerNight,
    'pricePerNight': pricePerNight,
    'totalPrice': totalPrice,
    'beds': beds,
    'roomType': roomType,
    'amenities': amenities,
    'freeCancellation': freeCancellation,
    'description': description,
    'image': image,
    'nights': nights,
    'savedAt': savedAt.toIso8601String(),
  };
}
