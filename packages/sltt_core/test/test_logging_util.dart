import 'package:logging/logging.dart';
import 'package:sltt_core/src/logging.dart';

/// Utility for tests to configure logging verbosity.
void enableTestLogging({Level level = Level.WARNING}) {
  SlttLogger.init(level: level);
}
