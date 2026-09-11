enum SavedItemCategory {
  flight,
  hotel,
  transport,
  activity,
  restaurant,
  place,
}

class SavedItem {
  const SavedItem({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.provider,
    required this.savedAt,
    this.price,
    this.currency,
    this.scheduledAt,
    this.notes,
    this.metadata = const {},
  });

  final String id;
  final SavedItemCategory category;
  final String title;
  final String subtitle;
  final String location;
  final String provider;
  final DateTime savedAt;
  final double? price;
  final String? currency;
  final DateTime? scheduledAt;
  final String? notes;
  final Map<String, dynamic> metadata;

  bool get isBookable =>
      category == SavedItemCategory.flight ||
      category == SavedItemCategory.hotel ||
      category == SavedItemCategory.transport;

  bool get isTripActivity =>
      category == SavedItemCategory.activity ||
      category == SavedItemCategory.restaurant ||
      category == SavedItemCategory.place;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'title': title,
      'subtitle': subtitle,
      'location': location,
      'provider': provider,
      'savedAt': savedAt.toIso8601String(),
      'price': price,
      'currency': currency,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'notes': notes,
      'metadata': metadata,
    };
  }

  factory SavedItem.fromJson(Map<String, dynamic> json) {
    return SavedItem(
      id: json['id'] as String,
      category: SavedItemCategory.values.firstWhere(
        (category) => category.name == json['category'],
        orElse: () => SavedItemCategory.place,
      ),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      location: json['location'] as String? ?? '',
      provider: json['provider'] as String? ?? '',
      savedAt:
          DateTime.tryParse(json['savedAt'] as String? ?? '') ?? DateTime.now(),
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      scheduledAt: DateTime.tryParse(json['scheduledAt'] as String? ?? ''),
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? const {}),
    );
  }
}
