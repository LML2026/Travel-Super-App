import 'package:intl/intl.dart';

class HotelSearchRequest {
  final String city;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guests;
  final int rooms;

  const HotelSearchRequest({
    required this.city,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guests,
    required this.rooms,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    final formatter = DateFormat('yyyy-MM-dd');
    return {
      'city': city,
      'checkInDate': formatter.format(checkInDate),
      'checkOutDate': formatter.format(checkOutDate),
      'guests': guests,
      'rooms': rooms,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HotelSearchRequest &&
          runtimeType == other.runtimeType &&
          city == other.city &&
          checkInDate == other.checkInDate &&
          checkOutDate == other.checkOutDate &&
          guests == other.guests &&
          rooms == other.rooms;

  @override
  int get hashCode =>
      city.hashCode ^
      checkInDate.hashCode ^
      checkOutDate.hashCode ^
      guests.hashCode ^
      rooms.hashCode;
}
