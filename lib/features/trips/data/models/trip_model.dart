import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/trip.dart';

class TripModel extends Trip {
  TripModel({
    required String id,
    required String title,
    required String destination,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? departureDate,
    DateTime? returnDate,
    required double budget,
    String? notes,
    String? imageUrl,
    String? currency,
    int? travellers,
    String? selectedFlightId,
    String? selectedHotelId,
    Map<String, dynamic>? weatherSnapshot,
    DateTime? weatherSnapshotCapturedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) : super(
         id: id,
         title: title,
         destination: destination,
         startDate: startDate,
         endDate: endDate,
         departureDate: departureDate,
         returnDate: returnDate,
         budget: budget,
         notes: notes,
         imageUrl: imageUrl,
         currency: currency,
         travellers: travellers,
         selectedFlightId: selectedFlightId,
         selectedHotelId: selectedHotelId,
         weatherSnapshot: weatherSnapshot,
         weatherSnapshotCapturedAt: weatherSnapshotCapturedAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
         status: status,
       );

  factory TripModel.fromJson(Map<String, dynamic> json) {
    DateTime? toDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      }
      if (value is DateTime) {
        return value;
      }
      if (value == null) {
        return null;
      }
      return DateTime.tryParse(value.toString());
    }

    return TripModel(
      id: json['id'] as String,
      title: json['title'] as String,
      destination: json['destination'] as String,
      startDate: toDate(json['startDate']) ?? toDate(json['departureDate']),
      endDate: toDate(json['endDate']) ?? toDate(json['returnDate']),
      budget: (json['budget'] as num).toDouble(),
      notes: json['notes'] as String?,
      imageUrl: json['imageUrl'] as String?,
      currency: json['currency'] as String?,
      travellers: (json['travellers'] as num?)?.toInt(),
      selectedFlightId: json['selectedFlightId'] as String?,
      selectedHotelId: json['selectedHotelId'] as String?,
      weatherSnapshot: json['weatherSnapshot'] as Map<String, dynamic>?,
      weatherSnapshotCapturedAt: toDate(json['weatherSnapshotCapturedAt']),
      createdAt: toDate(json['createdAt']),
      updatedAt: toDate(json['updatedAt']),
      status: json['status'] as String?,
    );
  }

  factory TripModel.fromEntity(Trip trip) {
    return TripModel(
      id: trip.id,
      title: trip.title,
      destination: trip.destination,
      startDate: trip.startDate,
      endDate: trip.endDate,
      departureDate: trip.departureDate,
      returnDate: trip.returnDate,
      budget: trip.budget,
      notes: trip.notes,
      imageUrl: trip.imageUrl,
      currency: trip.currency,
      travellers: trip.travellers,
      selectedFlightId: trip.selectedFlightId,
      selectedHotelId: trip.selectedHotelId,
      weatherSnapshot: trip.weatherSnapshot,
      weatherSnapshotCapturedAt: trip.weatherSnapshotCapturedAt,
      createdAt: trip.createdAt,
      updatedAt: trip.updatedAt,
      status: trip.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'departureDate': Timestamp.fromDate(departureDate),
      'returnDate': Timestamp.fromDate(returnDate),
      'budget': budget,
      'notes': notes,
      'imageUrl': imageUrl,
      'currency': currency,
      'travellers': travellers,
      'selectedFlightId': selectedFlightId,
      'selectedHotelId': selectedHotelId,
      'weatherSnapshot': weatherSnapshot,
      'weatherSnapshotCapturedAt': weatherSnapshotCapturedAt == null
          ? null
          : Timestamp.fromDate(weatherSnapshotCapturedAt!),
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
      'status': status,
    };
  }
}
