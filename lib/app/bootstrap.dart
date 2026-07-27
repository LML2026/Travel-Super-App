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

  await dotenv.load();
  await loggerService.initialize();
  loggerService.info('Bootstrapping Travel Super App');

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
