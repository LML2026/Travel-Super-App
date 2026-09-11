import '../../../core/models/booking.dart';
import '../../expenses/domain/entities/expense.dart';
import '../../trips/domain/entities/trip.dart';
import '../../trips/domain/entities/trip_activity.dart';
import '../../ai/domain/ai_travel_context.dart';

enum AiPlannerPace {
  relaxed,
  balanced,
  packed,
}

enum AiPlannerSuggestionStatus {
  proposed,
  accepted,
  rejected,
}

class AiPlannerPreferences {
  const AiPlannerPreferences({
    this.interests = const <String>{'culture', 'food'},
    this.pace = AiPlannerPace.balanced,
    this.familyFriendly = false,
    this.accessibility = false,
    this.rainyDay = false,
    this.cheaperPlan = false,
  });

  final Set<String> interests;
  final AiPlannerPace pace;
  final bool familyFriendly;
  final bool accessibility;
  final bool rainyDay;
  final bool cheaperPlan;

  AiPlannerPreferences copyWith({
    Set<String>? interests,
    AiPlannerPace? pace,
    bool? familyFriendly,
    bool? accessibility,
    bool? rainyDay,
    bool? cheaperPlan,
  }) {
    return AiPlannerPreferences(
      interests: interests ?? this.interests,
      pace: pace ?? this.pace,
      familyFriendly: familyFriendly ?? this.familyFriendly,
      accessibility: accessibility ?? this.accessibility,
      rainyDay: rainyDay ?? this.rainyDay,
      cheaperPlan: cheaperPlan ?? this.cheaperPlan,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interests': interests.toList(growable: false)..sort(),
      'pace': pace.name,
      'familyFriendly': familyFriendly,
      'accessibility': accessibility,
      'rainyDay': rainyDay,
      'cheaperPlan': cheaperPlan,
    };
  }

  factory AiPlannerPreferences.fromJson(Map<String, dynamic> json) {
    return AiPlannerPreferences(
      interests: (json['interests'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toSet(),
      pace: AiPlannerPace.values.firstWhere(
        (pace) => pace.name == json['pace'],
        orElse: () => AiPlannerPace.balanced,
      ),
      familyFriendly: json['familyFriendly'] as bool? ?? false,
      accessibility: json['accessibility'] as bool? ?? false,
      rainyDay: json['rainyDay'] as bool? ?? false,
      cheaperPlan: json['cheaperPlan'] as bool? ?? false,
    );
  }
}

class AiPlannerContext {
  const AiPlannerContext({
    required this.trip,
    required this.activities,
    required this.bookings,
    required this.expenses,
    required this.preferences,
    this.prompt,
    this.travelContext,
  });

  final Trip trip;
  final List<TripActivity> activities;
  final List<Booking> bookings;
  final List<Expense> expenses;
  final AiPlannerPreferences preferences;
  final String? prompt;
  final AiTravelContext? travelContext;
}

class AiPlannerSuggestion {
  const AiPlannerSuggestion({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.startTime,
    required this.durationMinutes,
    required this.estimatedCost,
    required this.currency,
    required this.notes,
    this.status = AiPlannerSuggestionStatus.proposed,
    this.conflictReason,
  });

  final String id;
  final String title;
  final String category;
  final String location;
  final DateTime startTime;
  final int durationMinutes;
  final double estimatedCost;
  final String currency;
  final String notes;
  final AiPlannerSuggestionStatus status;
  final String? conflictReason;

  AiPlannerSuggestion copyWith({
    String? id,
    String? title,
    String? category,
    String? location,
    DateTime? startTime,
    int? durationMinutes,
    double? estimatedCost,
    String? currency,
    String? notes,
    AiPlannerSuggestionStatus? status,
    String? conflictReason,
  }) {
    return AiPlannerSuggestion(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      conflictReason: conflictReason ?? this.conflictReason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'location': location,
      'startTime': startTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'estimatedCost': estimatedCost,
      'currency': currency,
      'notes': notes,
      'status': status.name,
      'conflictReason': conflictReason,
    };
  }

  factory AiPlannerSuggestion.fromJson(Map<String, dynamic> json) {
    return AiPlannerSuggestion(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'activity',
      location: json['location'] as String? ?? '',
      startTime: DateTime.tryParse(json['startTime']?.toString() ?? '') ??
          DateTime.now(),
      durationMinutes: json['durationMinutes'] as int? ?? 90,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'GBP',
      notes: json['notes'] as String? ?? '',
      status: AiPlannerSuggestionStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => AiPlannerSuggestionStatus.proposed,
      ),
      conflictReason: json['conflictReason'] as String?,
    );
  }
}

class AiPlannerDayPlan {
  const AiPlannerDayPlan({
    required this.date,
    required this.theme,
    required this.suggestions,
  });

  final DateTime date;
  final String theme;
  final List<AiPlannerSuggestion> suggestions;

  double get estimatedCost => suggestions.fold<double>(
        0,
        (total, suggestion) => total + suggestion.estimatedCost,
      );

  AiPlannerDayPlan copyWith({
    DateTime? date,
    String? theme,
    List<AiPlannerSuggestion>? suggestions,
  }) {
    return AiPlannerDayPlan(
      date: date ?? this.date,
      theme: theme ?? this.theme,
      suggestions: suggestions ?? this.suggestions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'theme': theme,
      'suggestions': suggestions
          .map((suggestion) => suggestion.toJson())
          .toList(growable: false),
    };
  }

  factory AiPlannerDayPlan.fromJson(Map<String, dynamic> json) {
    return AiPlannerDayPlan(
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      theme: json['theme'] as String? ?? '',
      suggestions: (json['suggestions'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AiPlannerSuggestion.fromJson)
          .toList(growable: false),
    );
  }
}

class AiPlannerPlan {
  const AiPlannerPlan({
    this.id = '',
    this.tripId = '',
    this.version = 1,
    required this.generatedAt,
    DateTime? updatedAt,
    required this.summary,
    required this.days,
    required this.totalEstimatedCost,
    required this.currency,
    required this.source,
    this.contextFingerprint = '',
    this.preferences = const AiPlannerPreferences(),
    this.prompt,
  }) : updatedAt = updatedAt ?? generatedAt;

  final String id;
  final String tripId;
  final int version;
  final DateTime generatedAt;
  final DateTime? updatedAt;
  final String summary;
  final List<AiPlannerDayPlan> days;
  final double totalEstimatedCost;
  final String currency;
  final String source;
  final String contextFingerprint;
  final AiPlannerPreferences preferences;
  final String? prompt;

  AiPlannerPlan copyWith({
    String? id,
    String? tripId,
    int? version,
    DateTime? generatedAt,
    DateTime? updatedAt,
    String? summary,
    List<AiPlannerDayPlan>? days,
    double? totalEstimatedCost,
    String? currency,
    String? source,
    String? contextFingerprint,
    AiPlannerPreferences? preferences,
    String? prompt,
  }) {
    return AiPlannerPlan(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      version: version ?? this.version,
      generatedAt: generatedAt ?? this.generatedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      summary: summary ?? this.summary,
      days: days ?? this.days,
      totalEstimatedCost: totalEstimatedCost ?? this.totalEstimatedCost,
      currency: currency ?? this.currency,
      source: source ?? this.source,
      contextFingerprint: contextFingerprint ?? this.contextFingerprint,
      preferences: preferences ?? this.preferences,
      prompt: prompt ?? this.prompt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'version': version,
      'generatedAt': generatedAt.toIso8601String(),
      'updatedAt': (updatedAt ?? generatedAt).toIso8601String(),
      'summary': summary,
      'days': days.map((day) => day.toJson()).toList(growable: false),
      'totalEstimatedCost': totalEstimatedCost,
      'currency': currency,
      'source': source,
      'contextFingerprint': contextFingerprint,
      'preferences': preferences.toJson(),
      'prompt': prompt,
    };
  }

  factory AiPlannerPlan.fromJson(Map<String, dynamic> json) {
    final generatedAt =
        DateTime.tryParse(json['generatedAt']?.toString() ?? '') ??
            DateTime.now();
    return AiPlannerPlan(
      id: json['id'] as String? ?? '',
      tripId: json['tripId'] as String? ?? '',
      version: json['version'] as int? ?? 1,
      generatedAt: generatedAt,
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? generatedAt,
      summary: json['summary'] as String? ?? '',
      days: (json['days'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AiPlannerDayPlan.fromJson)
          .toList(growable: false),
      totalEstimatedCost: (json['totalEstimatedCost'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'GBP',
      source: json['source'] as String? ?? 'local-demo',
      contextFingerprint: json['contextFingerprint'] as String? ?? '',
      preferences: AiPlannerPreferences.fromJson(
        json['preferences'] as Map<String, dynamic>? ?? const {},
      ),
      prompt: json['prompt'] as String?,
    );
  }
}
