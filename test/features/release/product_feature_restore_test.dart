import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/core/constants/supported_currencies.dart';
import 'package:travel_super_app/features/nearby/models/nearby_service_metadata.dart';
import 'package:travel_super_app/features/nearby/models/nearby_service_type.dart';
import 'package:travel_super_app/features/nearby/services/nearby_service_engine.dart';
import 'package:travel_super_app/features/translator/data/speech_service.dart';
import 'package:travel_super_app/features/translator/domain/translation_models.dart';
import 'package:travel_super_app/features/wallet/presentation/providers/wallet_provider.dart';

void main() {
  test('translator exposes exactly 19 user-selectable target languages', () {
    final selectableTargets =
        travelLanguages.where((language) => language.code != 'auto').toList();

    expect(selectableTargets, hasLength(19));
    expect(
      selectableTargets.map((language) => language.code),
      const <String>[
        'en',
        'fr',
        'es',
        'it',
        'de',
        'pt',
        'ja',
        'ar',
        'bg',
        'cs',
        'da',
        'el',
        'nl',
        'pl',
        'ro',
        'ru',
        'sv',
        'tr',
        'zh',
      ],
    );
    expect(supportedTranslationLanguageCodes, contains('auto'));
    expect(supportedTranslationTargetLanguageCodes, isNot(contains('auto')));
    expect(speechLocaleFor('zh'), 'zh-CN');
  });

  test('wallet and trip flows share the canonical travel currency list', () {
    expect(kSupportedWalletCurrencies, same(kSupportedTravelCurrencies));
    expect(
      kSupportedTravelCurrencies,
      containsAll(const <String>[
        'GBP',
        'EUR',
        'USD',
        'GEL',
        'RUB',
        'TRY',
        'AED',
        'CHF',
        'CAD',
        'AUD',
        'NZD',
        'JPY',
        'CNY',
        'HKD',
        'SGD',
        'INR',
        'KRW',
        'THB',
        'SEK',
        'NOK',
        'DKK',
        'PLN',
        'CZK',
        'HUF',
        'RON',
        'BGN',
        'ZAR',
        'BRL',
        'MXN',
        'SAR',
        'QAR',
        'ILS',
      ]),
    );
  });

  test('nearby essentials exposes approved services via Google categories', () {
    const approvedServices = <NearbyServiceType>[
      NearbyServiceType.toilet,
      NearbyServiceType.supermarket,
      NearbyServiceType.parking,
      NearbyServiceType.fuel,
      NearbyServiceType.trainStation,
      NearbyServiceType.busStation,
      NearbyServiceType.airport,
      NearbyServiceType.pharmacy,
      NearbyServiceType.hospital,
      NearbyServiceType.atm,
      NearbyServiceType.evCharging,
      NearbyServiceType.restaurant,
      NearbyServiceType.cafe,
      NearbyServiceType.attraction,
      NearbyServiceType.taxi,
      NearbyServiceType.transit,
    ];

    expect(nearbyEssentialsMvpServices, containsAll(approvedServices));

    const engine = NearbyServiceEngine();
    for (final serviceType in approvedServices) {
      expect(
        engine.categoriesFor(serviceType),
        isNotEmpty,
        reason: serviceType.name,
      );
    }
  });
}
