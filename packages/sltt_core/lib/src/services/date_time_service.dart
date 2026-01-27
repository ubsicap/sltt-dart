/// static HLC (Hybrid Logical Clock) timestamp generator
/// that tracks the last date and time requested
/// to ensure monotonically increasing timestamps
/// if now is less than or equal to the last date saved
/// the last timestamp is incremented by 1 millisecond
class HlcTimestampGenerator {
  static DateTime _lastTimestamp = DateTime.now().toUtc();

  /// Generates a new (UTC) HLC timestamp.
  static DateTime generate({int incrementMsForMonotonicity = 1}) {
    final now = DateTime.now().toUtc();
    if (now.isAfter(
      _lastTimestamp.add(
        Duration(milliseconds: incrementMsForMonotonicity - 1),
      ),
    )) {
      _lastTimestamp = now;
    } else {
      // Increment last timestamp by incrementMsForMonotonicity
      _lastTimestamp = _lastTimestamp.add(
        Duration(milliseconds: incrementMsForMonotonicity),
      );
    }
    return _lastTimestamp;
  }
}
