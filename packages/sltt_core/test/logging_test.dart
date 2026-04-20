import 'package:logging/logging.dart';
import 'package:sltt_core/src/logging.dart';
import 'package:test/test.dart';

void main() {
  test('logger getter initializes root listener on first use', () async {
    const message = 'lazy init smoke test';
    final recordFuture = Logger.root.onRecord.firstWhere(
      (record) => record.loggerName == 'sltt_core' && record.message == message,
    );

    SlttLogger.logger.warning(message);

    final record = await recordFuture.timeout(const Duration(seconds: 1));
    expect(hierarchicalLoggingEnabled, isTrue);
    expect(record.level, Level.WARNING);
  });

  test('root logger receives records from SlttLogger', () async {
    SlttLogger.init(level: SlttLogLevel.info);

    expect(hierarchicalLoggingEnabled, isTrue);

    const message = 'root propagation smoke test';
    final recordFuture = Logger.root.onRecord.firstWhere(
      (record) => record.loggerName == 'sltt_core' && record.message == message,
    );

    SlttLogger.logger.info(message);

    final record = await recordFuture.timeout(const Duration(seconds: 1));
    expect(record.level, Level.INFO);
  });
}
