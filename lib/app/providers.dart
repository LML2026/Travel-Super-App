import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/services/firebase_service.dart';
import '../core/services/logger_service.dart';
import '../core/services/network_service.dart';
import '../core/services/storage_service.dart';
import 'router.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return const FirebaseService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final loggerServiceProvider = Provider<LoggerService>((ref) {
  return LoggerService();
});

final networkServiceProvider = Provider<NetworkService>((ref) {
  return NetworkService();
});

final appRouterProvider = Provider<GoRouter>((ref) {
  return createAppRouter(ref);
});
