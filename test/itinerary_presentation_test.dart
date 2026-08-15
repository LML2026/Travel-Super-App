import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itarevo/core/widgets/app_attention_card.dart';
import 'package:itarevo/core/widgets/app_itinerary_item.dart';
import 'package:itarevo/core/widgets/app_journey_connector.dart';
import 'package:itarevo/features/trips/models/itinerary/itinerary_item.dart';
import 'package:itarevo/l10n/app_localizations.dart';

void main() {
  testWidgets('item hierarchy preserves itinerary values and callbacks', (
    tester,
  ) async {
    var opened = false;
    var edited = false;
    var deleted = false;
    final item = _item(
      title: 'National Museum of Modern and Contemporary Art',
      location:
          'A long location name that must remain readable on narrow phones',
      notes: 'Bring the reservation confirmation and allow time for entry.',
      isBooked: true,
      estimatedCost: 19.5,
      travelMinutesToNext: 15,
    );

    await tester.pumpWidget(
      _presentationApp(
        width: 360,
        child: AppItineraryItem(
          item: item,
          categoryIcon: Icons.photo_camera_outlined,
          bookedLabel: 'Booked',
          editLabel: 'Edit',
          deleteLabel: 'Delete',
          formatMinutes: (minutes) => '$minutes min',
          onOpen: () => opened = true,
          onEdit: () => edited = true,
          onDelete: () => deleted = true,
        ),
      ),
    );

    expect(find.text(item.time!), findsOneWidget);
    expect(find.text(item.title), findsOneWidget);
    expect(find.text(item.category), findsOneWidget);
    expect(find.text(item.location), findsOneWidget);
    expect(find.text(item.notes), findsOneWidget);
    expect(find.text('Booked'), findsOneWidget);
    expect(find.text('EUR 19.50'), findsOneWidget);
    expect(find.text('15 min'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Edit'));
    await tester.pump();
    await tester.tap(find.byTooltip('Delete'));
    await tester.pump();
    await tester.tap(find.text(item.title));
    await tester.pump();

    expect(edited, isTrue);
    expect(deleted, isTrue);
    expect(opened, isTrue);
  });

  testWidgets(
    'connectors show existing route data and accept missing route data',
    (tester) async {
      await tester.pumpWidget(
        _presentationApp(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppJourneyConnector(
                durationMinutes: 18,
                distanceMetres: 1400,
                travelModeLabel: 'walk',
                formatMinutes: (minutes) => '$minutes min',
                formatDistance: (metres) => '${metres / 1000} km',
              ),
              AppJourneyConnector(
                durationMinutes: null,
                distanceMetres: null,
                travelModeLabel: null,
                formatMinutes: (minutes) => '$minutes min',
                formatDistance: (metres) => '$metres m',
              ),
            ],
          ),
        ),
      );

      expect(find.text('18 min · 1.4 km · walk'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('attention card renders existing detail and action callback', (
    tester,
  ) async {
    var openedMap = false;

    await tester.pumpWidget(
      _presentationApp(
        width: 360,
        child: AppAttentionCard(
          title: 'Needs attention',
          detail: '2 locations need coordinates',
          actionLabel: 'Map',
          onAction: () => openedMap = true,
        ),
      ),
    );

    expect(find.text('Needs attention'), findsOneWidget);
    expect(find.text('2 locations need coordinates'), findsOneWidget);
    await tester.tap(find.text('Map'));
    await tester.pump();

    expect(openedMap, isTrue);
  });

  testWidgets('attention labels build across supported locale scripts', (
    tester,
  ) async {
    const locales = [
      Locale('en'),
      Locale('ru'),
      Locale('ar'),
      Locale('fa'),
      Locale('ka'),
      Locale('zh'),
      Locale('de'),
      Locale('fr'),
    ];

    for (final locale in locales) {
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return AppAttentionCard(
                title: l10n.needsAttention,
                detail: l10n.locationsNeedCoordinates(2),
                actionLabel: l10n.map,
                onAction: () {},
              );
            },
          ),
        ),
      );

      final card = tester.widget<AppAttentionCard>(
        find.byType(AppAttentionCard),
      );
      expect(card.title, isNotEmpty);
      expect(card.detail, isNotEmpty);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('item hierarchy builds safely at wide RTL constraints', (
    tester,
  ) async {
    const title = 'متحف الفن المعاصر ومركز المعارض الدولي';
    const location = 'شارع طويل للغاية في وسط المدينة التاريخي';

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: _presentationApp(
          width: 760,
          child: AppItineraryItem(
            item: _item(title: title, location: location),
            categoryIcon: Icons.photo_camera_outlined,
            bookedLabel: 'محجوز',
            editLabel: 'تعديل',
            deleteLabel: 'حذف',
            formatMinutes: (minutes) => '$minutes دقيقة',
            onOpen: () {},
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text(title), findsOneWidget);
    expect(find.text(location), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _presentationApp({required double width, required Widget child}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: width,
          child: SingleChildScrollView(child: child),
        ),
      ),
    ),
  );
}

ItineraryItem _item({
  String id = 'item',
  String title = 'National Museum',
  String location = 'Via Nazionale 1, Rome',
  String notes = 'Show ticket at entry.',
  bool isBooked = true,
  double? estimatedCost = 12.5,
  int? travelMinutesToNext,
  int? orderIndex,
  double? latitude,
  double? longitude,
}) {
  return ItineraryItem(
    id: id,
    tripId: 'trip',
    title: title,
    date: DateTime(2026, 9, 15),
    time: '08:30',
    location: location,
    category: 'Attraction',
    notes: notes,
    estimatedCost: estimatedCost,
    currency: 'EUR',
    isBooked: isBooked,
    latitude: latitude,
    longitude: longitude,
    travelMinutesToNext: travelMinutesToNext,
    orderIndex: orderIndex,
  );
}
