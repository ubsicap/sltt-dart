/// static HLC (Hybrid Logical Clock) timestamp generator
/// that tracks the last date and time requested
/// to ensure monotonically increasing timestamps
/// if now is less than or equal to the last date saved
/// the last timestamp is incremented by 1 millisecond
class HlcTimestampGenerator {
  static DateTime _lastTimestamp = DateTime.now().toUtc();

  /// Generates a new HLC timestamp.
  static DateTime generate() {
    final now = DateTime.now().toUtc();
    if (now.isAfter(_lastTimestamp)) {
      _lastTimestamp = now;
    } else {
      // Increment last timestamp by 1 millisecond to ensure monotonicity
      _lastTimestamp = _lastTimestamp.add(const Duration(milliseconds: 1));
    }
    return _lastTimestamp;
  }
}
