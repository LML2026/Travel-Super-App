class Hotel {
  final String id;
  final String name;
  final String image;
  final double rating;
  final String address;
  final String city;
  final double price;
  final String currency;
  final List<String> amenities;

  // Backward-compatible fields used by existing hotel details and save flows.
  final String country;
  final double totalPrice;
  final int beds;
  final String roomType;
  final bool freeCancellation;
  final String description;
  final List<String> imageGallery;
  final double latitude;
  final double longitude;
  final int nights;

  const Hotel({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.address,
    required this.city,
    required this.price,
    required this.currency,
    required this.amenities,
    this.country = '',
    double? totalPrice,
    this.beds = 1,
    this.roomType = 'Standard Room',
    this.freeCancellation = true,
    this.description =
        'Comfortable stay in a central location with curated amenities for modern travelers.',
    this.imageGallery = const ['🏨', '🛏️', '🌇'],
    this.latitude = 0,
    this.longitude = 0,
    this.nights = 1,
  }) : totalPrice = totalPrice ?? price;

  factory Hotel.fromJson(Map<String, dynamic> json) {
    final parsedCity = json['city']?.toString() ?? '';
    final parsedCountry =
        json['country']?.toString() ?? _defaultCountry(parsedCity);
    final parsedAddress =
        json['address']?.toString() ??
        _defaultAddress(parsedCity, parsedCountry);
    final parsedPrice =
        (json['price'] as num?)?.toDouble() ??
        (json['pricePerNight'] as num?)?.toDouble() ??
        0.0;
    final parsedAmenities = (json['amenities'] is List)
        ? List<String>.from(
            (json['amenities'] as List).map((e) => e.toString()),
          )
        : _defaultAmenities(parsedCity);
    final coordinates = _defaultCoordinates(parsedCity);

    return Hotel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Hotel',
      image: json['image']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      address: parsedAddress,
      city: parsedCity,
      price: parsedPrice,
      currency: json['currency']?.toString() ?? 'GBP',
      amenities: parsedAmenities,
      country: parsedCountry,
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      beds: int.tryParse(json['beds']?.toString() ?? '') ?? 1,
      roomType: json['roomType']?.toString() ?? _defaultRoomType(parsedCity),
      freeCancellation: json['freeCancellation'] == null
          ? true
          : json['freeCancellation'] == true,
      description:
          json['description']?.toString() ?? _defaultDescription(parsedCity),
      imageGallery: (json['imageGallery'] is List)
          ? List<String>.from(
              (json['imageGallery'] as List).map((e) => e.toString()),
            )
          : const ['🏨', '🛏️', '🌇'],
      latitude:
          double.tryParse(json['latitude']?.toString() ?? '') ?? coordinates.$1,
      longitude:
          double.tryParse(json['longitude']?.toString() ?? '') ??
          coordinates.$2,
      nights: int.tryParse(json['nights']?.toString() ?? '') ?? 1,
    );
  }

  double get pricePerNight => price;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'rating': rating,
      'address': address,
      'city': city,
      'price': price,
      'currency': currency,
      'amenities': amenities,
      'country': country,
      'pricePerNight': pricePerNight,
      'totalPrice': totalPrice,
      'beds': beds,
      'roomType': roomType,
      'freeCancellation': freeCancellation,
      'description': description,
      'imageGallery': imageGallery,
      'latitude': latitude,
      'longitude': longitude,
      'nights': nights,
    };
  }

  static String _defaultCountry(String city) {
    switch (city.toLowerCase()) {
      case 'paris':
        return 'France';
      case 'london':
        return 'United Kingdom';
      case 'barcelona':
        return 'Spain';
      case 'new york':
        return 'United States';
      case 'tokyo':
        return 'Japan';
      default:
        return '';
    }
  }

  static String _defaultAddress(String city, String country) {
    if (city.isEmpty) {
      return 'Central district';
    }

    if (country.isEmpty) {
      return '$city City Center';
    }

    return '$city, $country';
  }

  static List<String> _defaultAmenities(String city) {
    switch (city.toLowerCase()) {
      case 'paris':
        return const ['Free Wi-Fi', 'Breakfast Included', 'Free Cancellation'];
      case 'london':
        return const ['Free Wi-Fi', 'Late Check-in', 'Gym Access'];
      case 'barcelona':
        return const ['Beach Shuttle', 'Free Wi-Fi', 'Breakfast Included'];
      default:
        return const ['Free Wi-Fi', 'Breakfast Included', '24h Front Desk'];
    }
  }

  static String _defaultRoomType(String city) {
    switch (city.toLowerCase()) {
      case 'paris':
        return 'Deluxe Queen Room';
      case 'london':
        return 'Executive Double Room';
      case 'tokyo':
        return 'Premium City View Room';
      default:
        return 'Standard Room';
    }
  }

  static String _defaultDescription(String city) {
    if (city.isEmpty) {
      return 'Comfortable stay with modern amenities and easy transport access.';
    }

    return 'A stylish stay in $city with modern comforts, local dining nearby, and convenient transport links.';
  }

  static (double, double) _defaultCoordinates(String city) {
    switch (city.toLowerCase()) {
      case 'paris':
        return (48.8566, 2.3522);
      case 'london':
        return (51.5072, -0.1276);
      case 'barcelona':
        return (41.3851, 2.1734);
      case 'new york':
        return (40.7128, -74.0060);
      case 'tokyo':
        return (35.6762, 139.6503);
      default:
        return (0, 0);
    }
  }
}
