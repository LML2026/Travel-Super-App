class RecentSearch {
  final String id;
  final String from;
  final String to;
  final String departureDate;
  final String? returnDate;
  final int passengers;
  final String cabinClass;
  final DateTime searchedAt;

  const RecentSearch({
    required this.id,
    required this.from,
    required this.to,
    required this.departureDate,
    this.returnDate,
    required this.passengers,
    required this.cabinClass,
    required this.searchedAt,
  });

  factory RecentSearch.fromJson(Map<String, dynamic> json) {
    return RecentSearch(
      id: json['id'] as String? ?? '',
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      departureDate: json['departureDate'] as String? ?? '',
      returnDate: json['returnDate'] as String?,
      passengers: json['passengers'] as int? ?? 1,
      cabinClass: json['cabinClass'] as String? ?? 'economy',
      searchedAt: json['searchedAt'] != null
          ? DateTime.parse(json['searchedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'from': from,
    'to': to,
    'departureDate': departureDate,
    'returnDate': returnDate,
    'passengers': passengers,
    'cabinClass': cabinClass,
    'searchedAt': searchedAt.toIso8601String(),
  };
}
