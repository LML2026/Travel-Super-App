import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/trip.dart';

class TripModel {
	const TripModel({
		required this.id,
		required this.destination,
		required this.departureDate,
		required this.returnDate,
		required this.budget,
		required this.currency,
		required this.travellers,
		required this.notes,
	});

	final String id;
	final String destination;
	final DateTime departureDate;
	final DateTime returnDate;
	final double budget;
	final String currency;
	final int travellers;
	final String notes;

	factory TripModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
		final data = doc.data() ?? const <String, dynamic>{};

		DateTime readDate(dynamic raw) {
			if (raw is Timestamp) {
				return raw.toDate();
			}
			if (raw is DateTime) {
				return raw;
			}
			if (raw is String) {
				return DateTime.tryParse(raw) ?? DateTime.now();
			}
			return DateTime.now();
		}

		return TripModel(
			id: doc.id,
			destination: (data['destination'] ?? '').toString(),
			departureDate: readDate(data['departureDate']),
			returnDate: readDate(data['returnDate']),
			budget: (data['budget'] as num?)?.toDouble() ?? 0,
			currency: (data['currency'] ?? 'GBP').toString(),
			travellers: (data['travellers'] as num?)?.toInt() ?? 1,
			notes: (data['notes'] ?? '').toString(),
		);
	}

	factory TripModel.fromEntity(Trip entity) {
		return TripModel(
			id: entity.id,
			destination: entity.destination,
			departureDate: entity.departureDate,
			returnDate: entity.returnDate,
			budget: entity.budget,
			currency: entity.currency,
			travellers: entity.travellers,
			notes: entity.notes,
		);
	}

	Trip toEntity() {
		return Trip(
			id: id,
			destination: destination,
			departureDate: departureDate,
			returnDate: returnDate,
			budget: budget,
			currency: currency,
			travellers: travellers,
			notes: notes,
		);
	}

	Map<String, dynamic> toCreateMap() {
		return <String, dynamic>{
			'destination': destination,
			'departureDate': Timestamp.fromDate(departureDate),
			'returnDate': Timestamp.fromDate(returnDate),
			'budget': budget,
			'currency': currency,
			'travellers': travellers,
			'notes': notes,
			'createdAt': FieldValue.serverTimestamp(),
			'updatedAt': FieldValue.serverTimestamp(),
		};
	}

	Map<String, dynamic> toUpdateMap() {
		return <String, dynamic>{
			'destination': destination,
			'departureDate': Timestamp.fromDate(departureDate),
			'returnDate': Timestamp.fromDate(returnDate),
			'budget': budget,
			'currency': currency,
			'travellers': travellers,
			'notes': notes,
			'updatedAt': FieldValue.serverTimestamp(),
		};
	}
}
