class NearbyServiceFilter {
  const NearbyServiceFilter({
    this.openNow = false,
    this.maxDistanceMeters,
    this.minRating,
    this.wheelchairAccessible = false,
    this.freeOnly = false,
    this.babyChanging = false,
  });

  final bool openNow;
  final int? maxDistanceMeters;
  final double? minRating;
  final bool wheelchairAccessible;
  final bool freeOnly;
  final bool babyChanging;

  NearbyServiceFilter copyWith({
    bool? openNow,
    int? maxDistanceMeters,
    double? minRating,
    bool? wheelchairAccessible,
    bool? freeOnly,
    bool? babyChanging,
  }) {
    return NearbyServiceFilter(
      openNow: openNow ?? this.openNow,
      maxDistanceMeters: maxDistanceMeters ?? this.maxDistanceMeters,
      minRating: minRating ?? this.minRating,
      wheelchairAccessible:
          wheelchairAccessible ?? this.wheelchairAccessible,
      freeOnly: freeOnly ?? this.freeOnly,
      babyChanging: babyChanging ?? this.babyChanging,
    );
  }
}