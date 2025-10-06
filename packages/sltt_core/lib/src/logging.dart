import 'dart:io';

import 'package:logging/logging.dart';

/// Simple project-wide logger wrapper.
/// Default level is WARNING to keep test output quiet. Set the
/// environment variable `SLTT_LOG_LEVEL` to one of: ALL, FINE, INFO, WARNING, SEVERE
/// to change behavior in CI or locally.
class SlttLogger {
  // Do not set a non-root logger's level directly because changing the
  // level of a non-root logger requires enabling hierarchical logging.
  // Instead, we control logging by setting Logger.root.level only.
  static final Logger _logger = Logger('sltt_core');

  static bool _initialized = false;

  static void init({Level level = Level.WARNING}) {
    // Prefer SLTT_LOG_LEVEL env var, then an explicit argument (default WARNING)
    // Read the environment in a try/catch because
    // some test runners restrict access to Platform.environment.
    Level? envLevel;
    try {
      final env = Platform.environment['SLTT_LOG_LEVEL'];
      if (env != null && env.isNotEmpty) envLevel = _levelFromName(env);
    } catch (_) {
      // ignore environment access errors
    }

    Logger.root.level = envLevel ?? level;
    // Root level is now controlled via Logger.root.level above.

    // Only add a handler once.
    if (!_initialized) {
      Logger.root.onRecord.listen((record) {
        // Build a single string to print so tests that capture stdout see a
        // coherent message rather than multiple print calls. Keep previous
        // format but include optional error/stack on following lines.
        final buffer = StringBuffer();
        buffer.write(
          '[${record.level.name}] ${record.time.toIso8601String()} ${record.loggerName}: ${record.message}',
        );
        if (record.error != null) buffer.write('\n${record.error}');
        if (record.stackTrace != null) buffer.write('\n${record.stackTrace}');
        print(buffer.toString());
      });
      _initialized = true;
    }
  }

  static void setLevel(Level level) {
    Logger.root.level = level;
  }

  static Logger get logger => _logger;
}

// Auto-initialize logger on import so SLTT_LOG_LEVEL (if set) takes effect
// without needing to call SlttLogger.init() from test code. This is a
// best-effort call and failures are ignored so test runners that
// restrict environment access won't crash. We perform the init inside a
// final initializer closure (an expression) so the library stays valid
// and the analyzer won't complain about top-level statements.
// Run init at library load time. Using a final and an explicit ignore so
// the analyzer won't complain about the symbol being unused. This
// executes SlttLogger.init() when the library is loaded.
// ignore: unused_element
final _slttLoggerAutoInit = _runSlttLoggerInit();

int _runSlttLoggerInit() {
  try {
    SlttLogger.init();
  } catch (_) {
    // ignore any environment access restrictions
  }
  return 0;
}

Level? _levelFromName(String name) {
  switch (name.toUpperCase()) {
    case 'ALL':
      return Level.ALL;
    case 'FINE':
    case 'DEBUG':
      return Level.FINE;
    case 'INFO':
      return Level.INFO;
    case 'WARNING':
    case 'WARN':
      return Level.WARNING;
    case 'SEVERE':
    case 'ERROR':
      return Level.SEVERE;
    case 'OFF':
      return Level.OFF;
    default:
      return null;
  }
}
