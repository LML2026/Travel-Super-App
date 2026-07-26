class RecentHotelSearch {
  final String id;
  final String city;
  final String checkInDate;
  final String checkOutDate;
  final int guests;
  final int rooms;
  final DateTime searchedAt;

  const RecentHotelSearch({
    required this.id,
    required this.city,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guests,
    required this.rooms,
    required this.searchedAt,
  });

  factory RecentHotelSearch.fromJson(Map<String, dynamic> json) {
    return RecentHotelSearch(
      id: json['id'] as String? ?? '',
      city: json['city'] as String? ?? '',
      checkInDate: json['checkInDate'] as String? ?? '',
      checkOutDate: json['checkOutDate'] as String? ?? '',
      guests: json['guests'] as int? ?? 1,
      rooms: json['rooms'] as int? ?? 1,
      searchedAt: json['searchedAt'] != null
          ? DateTime.parse(json['searchedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'city': city,
    'checkInDate': checkInDate,
    'checkOutDate': checkOutDate,
    'guests': guests,
    'rooms': rooms,
    'searchedAt': searchedAt.toIso8601String(),
  };
}
