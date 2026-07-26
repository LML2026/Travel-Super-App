class Trip {
	final String id;
	final String destination;
	final DateTime departureDate;
	final DateTime returnDate;
	final double budget;
	final String currency;
	final int travellers;
	final String notes;

	const Trip({
		required this.id,
		required this.destination,
		required this.departureDate,
		required this.returnDate,
		required this.budget,
		required this.currency,
		required this.travellers,
		required this.notes,
	});
}
