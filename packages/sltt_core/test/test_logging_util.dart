import 'package:sltt_core/src/logging.dart';

/// Utility for tests to configure logging verbosity.
void enableTestLogging({SlttLogLevel level = SlttLogLevel.warning}) {
  SlttLogger.init(level: level);
}
