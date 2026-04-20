import 'dart:async' show Completer;
import 'dart:collection' show Queue;
import 'dart:math' show min;

Future<void> runWithConcurrency<T>({
  required List<T> items,
  required int concurrency,
  required Future<void> Function(T item) worker,
}) async {
  if (items.isEmpty) return;

  final capped = concurrency <= 0 ? 1 : min(concurrency, items.length);
  var index = 0;

  Future<void> runWorker() async {
    while (true) {
      if (index >= items.length) return;
      final item = items[index++];
      await worker(item);
    }
  }

  await Future.wait(List.generate(capped, (_) => runWorker()));
}

class RequestLimiter {
  RequestLimiter(int permits)
    : _maxPermits = permits <= 0 ? 1 : permits,
      _permits = permits <= 0 ? 1 : permits;

  final int _maxPermits;
  int _permits;
  final Queue<Completer<void>> _waiters = Queue();

  int get inFlight => _maxPermits - _permits;
  int get maxPermits => _maxPermits;
  int get availablePermits => _permits;

  Future<void> acquire() {
    if (_permits > 0) {
      _permits--;
      return Future.value();
    }
    final completer = Completer<void>();
    _waiters.add(completer);
    return completer.future;
  }

  void release() {
    if (_waiters.isNotEmpty) {
      _waiters.removeFirst().complete();
      return;
    }
    _permits++;
  }
}
