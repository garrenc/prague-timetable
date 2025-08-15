import 'dart:developer' as developer;

class AppLogger {
  static void log(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    // Better use package for formatting, but this is faster
    final timestamp = DateTime.now().toString().substring(11, 23);

    developer.log('[$timestamp]: $message', name: 'PragueMHD', error: error, stackTrace: stackTrace);
  }

  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    log('❌ $message', tag: tag, error: error, stackTrace: stackTrace);
  }
}
