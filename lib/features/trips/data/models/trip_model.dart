import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/trip.dart';

class TripModel extends Trip {
  const TripModel({
    required super.id,
    required super.destination,
    required super.departureDate,
    required super.returnDate,
    required super.budget,
    required super.currency,
    required super.travellers,
    required super.notes,
    super.selectedFlightId,
    super.selectedHotelId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TripModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return TripModel(
      id: doc.id,
      destination: data['destination'] as String,
      departureDate:
          (data['departureDate'] as Timestamp).toDate(),
      returnDate:
          (data['returnDate'] as Timestamp).toDate(),
      budget: (data['budget'] as num).toDouble(),
      currency: data['currency'] as String,
      travellers: data['travellers'] as int,
      notes: data['notes'] as String? ?? '',
        selectedFlightId: data['selectedFlightId'] as String?,
        selectedHotelId: data['selectedHotelId'] as String?,
      createdAt:
          (data['createdAt'] as Timestamp).toDate(),
      updatedAt:
          (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory TripModel.fromEntity(Trip trip) {
    return TripModel(
      id: trip.id,
      destination: trip.destination,
      departureDate: trip.departureDate,
      returnDate: trip.returnDate,
      budget: trip.budget,
      currency: trip.currency,
      travellers: trip.travellers,
      notes: trip.notes,
      selectedFlightId: trip.selectedFlightId,
      selectedHotelId: trip.selectedHotelId,
      createdAt: trip.createdAt,
      updatedAt: trip.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'destination': destination,
      'departureDate': Timestamp.fromDate(departureDate),
      'returnDate': Timestamp.fromDate(returnDate),
      'budget': budget,
      'currency': currency,
      'travellers': travellers,
      'notes': notes,
      'selectedFlightId': selectedFlightId,
      'selectedHotelId': selectedHotelId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
