import 'dart:io';

import 'package:logging/logging.dart';

const String kSlttLogLevelAll = 'ALL';
const String kSlttLogLevelFine = 'FINE';
const String kSlttLogLevelInfo = 'INFO';
const String kSlttLogLevelWarning = 'WARNING';
const String kSlttLogLevelSevere = 'SEVERE';
const String kSlttLogLevelOff = 'OFF';

enum SlttLogLevel {
  all(value: kSlttLogLevelAll),
  fine(value: kSlttLogLevelFine),
  info(value: kSlttLogLevelInfo),
  warning(value: kSlttLogLevelWarning),
  severe(value: kSlttLogLevelSevere),
  off(value: kSlttLogLevelOff);

  final String value;
  const SlttLogLevel({required this.value});
}

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

  static void init({SlttLogLevel level = SlttLogLevel.warning}) {
    // Ensure records from named loggers propagate to the root listener.
    hierarchicalLoggingEnabled = true;

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

    Logger.root.level = envLevel ?? _levelFromName(level.value);
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

  static void setLevel(SlttLogLevel level) {
    Logger.root.level = _levelFromName(level.value);
  }

  static Logger get logger {
    if (!_initialized) {
      init();
    }
    return _logger;
  }
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
