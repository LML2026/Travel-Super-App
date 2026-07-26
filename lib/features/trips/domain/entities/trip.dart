class Trip {
	final String id;
	final String destination;
	final DateTime departureDate;
	final DateTime returnDate;
	final double budget;
	final String currency;
	final int travellers;
	final String notes;
	final String? selectedFlightId;
	final String? selectedHotelId;
	final DateTime createdAt;
	final DateTime updatedAt;

	const Trip({
		required this.id,
		required this.destination,
		required this.departureDate,
		required this.returnDate,
		required this.budget,
		required this.currency,
		required this.travellers,
		required this.notes,
		this.selectedFlightId,
		this.selectedHotelId,
		required this.createdAt,
		required this.updatedAt,
	});

	Trip copyWith({
		String? id,
		String? destination,
		DateTime? departureDate,
		DateTime? returnDate,
		double? budget,
		String? currency,
		int? travellers,
		String? notes,
		String? selectedFlightId,
		String? selectedHotelId,
		DateTime? createdAt,
		DateTime? updatedAt,
	}) {
		return Trip(
			id: id ?? this.id,
			destination: destination ?? this.destination,
			departureDate: departureDate ?? this.departureDate,
			returnDate: returnDate ?? this.returnDate,
			budget: budget ?? this.budget,
			currency: currency ?? this.currency,
			travellers: travellers ?? this.travellers,
			notes: notes ?? this.notes,
			selectedFlightId: selectedFlightId ?? this.selectedFlightId,
			selectedHotelId: selectedHotelId ?? this.selectedHotelId,
			createdAt: createdAt ?? this.createdAt,
			updatedAt: updatedAt ?? this.updatedAt,
		);
	}

	@override
	String toString() {
		return 'Trip('
				'id: $id, '
				'destination: $destination, '
				'departure: $departureDate, '
				'return: $returnDate'
				')';
	}

	@override
	bool operator ==(Object other) =>
			identical(this, other) ||
			other is Trip &&
				runtimeType == other.runtimeType &&
				id == other.id;

	@override
	int get hashCode => id.hashCode;
}
