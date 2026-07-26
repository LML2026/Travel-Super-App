class Hotel {
  final String id;
  final String name;
  final String city;
  final String country;
  final String address;
  final double rating;
  final double pricePerNight;
  final double totalPrice;
  final int beds;
  final String roomType;
  final List<String> amenities;
  final bool freeCancellation;
  final String description;
  final List<String> imageGallery;
  final double latitude;
  final double longitude;
  final String image;
  final int nights;

  const Hotel({
    required this.id,
    required this.name,
    required this.city,
    this.country = '',
    this.address = '',
    required this.rating,
    required this.pricePerNight,
    required this.totalPrice,
    required this.beds,
    this.roomType = 'Standard Room',
    this.amenities = const ['Free Wi-Fi', 'Breakfast Included'],
    this.freeCancellation = true,
    this.description =
        'Comfortable stay in a central location with curated amenities for modern travelers.',
    this.imageGallery = const ['🏨', '🛏️', '🌇'],
    this.latitude = 0,
    this.longitude = 0,
    required this.image,
    required this.nights,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    final city = json['city']?.toString() ?? '';
    final country = json['country']?.toString() ?? _defaultCountry(city);
    final address = json['address']?.toString() ?? _defaultAddress(city, country);
    final coordinates = _defaultCoordinates(city);
    final amenities = (json['amenities'] is List)
        ? List<String>.from((json['amenities'] as List).map((e) => e.toString()))
        : _defaultAmenities(city);

    return Hotel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      city: city,
      country: country,
      address: address,
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0.0,
      pricePerNight: double.tryParse(json['pricePerNight']?.toString() ?? '') ?? 0.0,
      totalPrice: double.tryParse(json['totalPrice']?.toString() ?? '') ?? 0.0,
      beds: int.tryParse(json['beds']?.toString() ?? '') ?? 1,
      roomType: json['roomType']?.toString() ?? _defaultRoomType(city),
      amenities: amenities,
      freeCancellation: json['freeCancellation'] == null
          ? true
          : json['freeCancellation'] == true,
      description: json['description']?.toString() ?? _defaultDescription(city),
      imageGallery: (json['imageGallery'] is List)
          ? List<String>.from((json['imageGallery'] as List).map((e) => e.toString()))
          : const ['🏨', '🛏️', '🌇'],
      latitude: double.tryParse(json['latitude']?.toString() ?? '') ?? coordinates.$1,
      longitude: double.tryParse(json['longitude']?.toString() ?? '') ?? coordinates.$2,
      image: json['image']?.toString() ?? '🏨',
      nights: int.tryParse(json['nights']?.toString() ?? '') ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'country': country,
      'address': address,
      'rating': rating,
      'pricePerNight': pricePerNight,
      'totalPrice': totalPrice,
      'beds': beds,
      'roomType': roomType,
      'amenities': amenities,
      'freeCancellation': freeCancellation,
      'description': description,
      'imageGallery': imageGallery,
      'latitude': latitude,
      'longitude': longitude,
      'image': image,
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
