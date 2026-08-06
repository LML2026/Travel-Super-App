import 'package:logger/logger.dart';

class LoggerService {
  LoggerService({Logger? logger}) : _logger = logger ?? Logger();

  final Logger _logger;

  Future<void> initialize() async {}

  void info(String message) {
    _logger.i(message);
  }

  void warning(String message) {
    _logger.w(message);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
