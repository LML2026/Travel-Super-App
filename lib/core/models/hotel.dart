class Hotel {
  final String id;
  final String name;
  final String city;
  final String address;
  final double pricePerNight;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final List<String> amenities;
  final int availableRooms;
  final String checkInTime;
  final String checkOutTime;

  Hotel({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.pricePerNight,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.amenities,
    required this.availableRooms,
    required this.checkInTime,
    required this.checkOutTime,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      address: json['address'] as String,
      pricePerNight: (json['pricePerNight'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      imageUrl: json['imageUrl'] as String,
      amenities: List<String>.from(json['amenities'] as List),
      availableRooms: json['availableRooms'] as int,
      checkInTime: json['checkInTime'] as String,
      checkOutTime: json['checkOutTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'address': address,
      'pricePerNight': pricePerNight,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'amenities': amenities,
      'availableRooms': availableRooms,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
    };
  }
}
