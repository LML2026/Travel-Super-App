import 'package:logger/logger.dart';

/// Global app logger.
/// Usage:
///   import 'package:travel_super_app/core/utils/app_logger.dart';
///   appLogger.i('Searching flights');
///   appLogger.e('API error', error: e, stackTrace: st);
final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
  ),
);
