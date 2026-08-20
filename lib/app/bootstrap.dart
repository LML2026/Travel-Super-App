import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/firebase_service.dart';
import '../core/services/logger_service.dart';
import '../core/services/network_service.dart';
import '../core/services/storage_service.dart';
import 'app.dart';
import 'providers.dart';

Future<void> bootstrap() async {
  final firebaseService = const FirebaseService();
  final storageService = StorageService();
  final loggerService = LoggerService();
  final networkService = NetworkService();

  await loggerService.initialize();
  loggerService.info('Bootstrapping Travel Super App');

  try {
    await dotenv.load(isOptional: true);
    final baseEnvironment = Map<String, String>.from(dotenv.env);
    await dotenv.load(
      fileName: '.env.local',
      mergeWith: baseEnvironment,
      isOptional: true,
    );
  } catch (error, stackTrace) {
    // Local/demo providers do not require environment configuration.
    loggerService.warning('Optional environment configuration unavailable.');
    loggerService.error(
        'Environment configuration load failed.', error, stackTrace);
  }

  await firebaseService.initialize();
  await storageService.initialize();
  await networkService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        firebaseServiceProvider.overrideWithValue(firebaseService),
        storageServiceProvider.overrideWithValue(storageService),
        loggerServiceProvider.overrideWithValue(loggerService),
        networkServiceProvider.overrideWithValue(networkService),
      ],
      child: const TravelSuperApp(),
    ),
  );
}
