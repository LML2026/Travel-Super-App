import '../models/nearby_service_result.dart';
import '../models/nearby_service_type.dart';

class NearbyProviderFallbackEngine {
  const NearbyProviderFallbackEngine();

  List<NearbyServiceResult> mergeResults({
    required NearbyServiceType serviceType,
    required List<NearbyServiceResult> primaryResults,
    required List<NearbyServiceResult> fallbackResults,
    required bool primaryFailed,
    int limit = 20,
  }) {
    final taggedPrimary = primaryResults
        .map(
          (result) => _withSourceMetadata(
            result,
            isFallback: false,
            fallbackReason: primaryFailed ? 'primary_failed' : null,
          ),
        )
        .toList(growable: false);

    final taggedFallback = fallbackResults
        .map(
          (result) => _withSourceMetadata(
            result,
            isFallback: true,
            fallbackReason:
                primaryFailed ? 'primary_failed' : 'quality_enrichment',
          ),
        )
        .toList(growable: false);

    if (primaryFailed || taggedPrimary.isEmpty) {
      return _rankByQuality(serviceType, taggedFallback)
          .take(limit)
          .toList(growable: false);
    }

    final combined = <NearbyServiceResult>[
      ...taggedPrimary,
      ...taggedFallback,
    ];
    final deduped = _dedupe(combined);
    return _rankByQuality(serviceType, deduped)
        .take(limit)
        .toList(growable: false);
  }

  NearbyServiceResult _withSourceMetadata(
    NearbyServiceResult result, {
    required bool isFallback,
    required String? fallbackReason,
  }) {
    final sourceMetadata = <String, Object?>{
      ...result.sourceMetadata,
      'fallbackApplied': isFallback,
      if (isFallback) 'upstreamSource': result.source.name,
      if (fallbackReason != null) 'fallbackReason': fallbackReason,
    };

    return NearbyServiceResult(
      id: result.id,
      name: result.name,
      serviceType: result.serviceType,
      categoryLabel: result.categoryLabel,
      address: result.address,
      latitude: result.latitude,
      longitude: result.longitude,
      source: isFallback ? NearbyDataSource.fallback : result.source,
      sourceMetadata: sourceMetadata,
      distanceMeters: result.distanceMeters,
      rating: result.rating,
      isOpenNow: result.isOpenNow,
      openingHours: result.openingHours,
      openStatusSource: result.openStatusSource,
      wheelchairAccessible: result.wheelchairAccessible,
      hasAccessibleToilet: result.hasAccessibleToilet,
      hasBabyChanging: result.hasBabyChanging,
      metadata: result.metadata,
    );
  }

  List<NearbyServiceResult> _dedupe(List<NearbyServiceResult> input) {
    final seen = <String>{};
    final output = <NearbyServiceResult>[];

    for (final result in input) {
      final key =
          '${result.name.toLowerCase()}|${result.address.toLowerCase()}';
      if (seen.add(key)) {
        output.add(result);
      }
    }

    return output;
  }

  List<NearbyServiceResult> _rankByQuality(
    NearbyServiceType serviceType,
    List<NearbyServiceResult> input,
  ) {
    final sorted = List<NearbyServiceResult>.from(input);
    sorted.sort((a, b) {
      final byScore = _score(serviceType, b).compareTo(_score(serviceType, a));
      if (byScore != 0) {
        return byScore;
      }

      final aDistance = a.distanceMeters;
      final bDistance = b.distanceMeters;
      if (aDistance == null && bDistance == null) {
        return 0;
      }
      if (aDistance == null) {
        return 1;
      }
      if (bDistance == null) {
        return -1;
      }
      return aDistance.compareTo(bDistance);
    });
    return sorted;
  }

  int _score(NearbyServiceType serviceType, NearbyServiceResult result) {
    var score = 0;

    if (result.isOpenNow == true) {
      score += 20;
    }
    if (result.openStatusSource != OpenStatusSource.unknown) {
      score += 8;
    }

    if (result.distanceMeters != null) {
      final distanceBonus =
          (5000 - result.distanceMeters!).clamp(0, 5000) ~/ 250;
      score += distanceBonus;
    }

    switch (serviceType) {
      case NearbyServiceType.toilet:
        if (result.hasAccessibleToilet == true) {
          score += 40;
        }
        if (result.wheelchairAccessible == true) {
          score += 30;
        }
        if (result.hasBabyChanging == true) {
          score += 15;
        }
        break;
      case NearbyServiceType.pharmacy:
        if (result.isOpenNow == true &&
            result.openStatusSource == OpenStatusSource.provider) {
          score += 45;
        } else if (result.isOpenNow == true) {
          score += 20;
        }
        break;
      default:
        break;
    }

    if (result.source == NearbyDataSource.fallback) {
      score -= 3;
    }

    return score;
  }
}
