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
	final Map<String, dynamic>? weatherSnapshot;
	final DateTime? weatherSnapshotCapturedAt;
	final DateTime? createdAt;
	final String status;

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
		this.weatherSnapshot,
		this.weatherSnapshotCapturedAt,
		this.createdAt,
		this.status = 'planned',
	});
}
