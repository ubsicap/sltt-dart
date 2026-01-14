import 'dart:async' show Completer;
import 'dart:collection' show Queue;
import 'dart:convert' show jsonDecode, jsonEncode, utf8;
import 'dart:io'
    show File, HttpClient, HttpClientResponse, HttpException, ContentType;
import 'dart:math' show min;

/// fast and memory-efficient file concatenation
Future<void> concatenateFiles({
  required List<File> parts,
  required File output,
}) async {
  final sink = output.openWrite();

  try {
    for (final part in parts) {
      await sink.addStream(part.openRead());
    }
  } finally {
    await sink.close();
  }
}

const maxConcurrency = 4;

class SignedUrlBundle {
  SignedUrlBundle({
    required this.remoteFileKey,
    this.headObject,
    this.getObject,
    this.uploadPart,
    this.partNumber,
    this.uploadId,
    this.expiresAt,
  });

  final String remoteFileKey;
  final Uri? headObject;
  final Uri? getObject;
  final Uri? uploadPart;
  final int? partNumber;
  final String? uploadId;
  final DateTime? expiresAt;

  factory SignedUrlBundle.fromJson(Map<String, dynamic> json) {
    DateTime? expires;
    final expiresRaw = json['expiresAt'];
    if (expiresRaw is String) {
      expires = DateTime.tryParse(expiresRaw);
    }

    return SignedUrlBundle(
      remoteFileKey: json['remoteFileKey'] as String,
      headObject: json['head_object'] != null
          ? Uri.parse(json['head_object'] as String)
          : null,
      getObject: json['get_object'] != null
          ? Uri.parse(json['get_object'] as String)
          : null,
      uploadPart: json['upload_part'] != null
          ? Uri.parse(json['upload_part'] as String)
          : null,
      partNumber: json['partNumber'] as int?,
      uploadId: json['uploadId'] as String?,
      expiresAt: expires,
    );
  }
}

class MediaApiClientCore {
  MediaApiClientCore(String baseUrl, {HttpClient? client})
    : baseUri = Uri.parse(baseUrl),
      httpClient = client ?? HttpClient();

  final Uri baseUri;
  final HttpClient httpClient;

  Future<HttpClientResponse> head(Uri url) async {
    final request = await httpClient.openUrl('HEAD', url);
    return request.close();
  }

  Future<HttpClientResponse> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    final request = await httpClient.getUrl(url);
    headers?.forEach(request.headers.set);
    return request.close();
  }

  Future<List<SignedUrlBundle>> getUrls({
    required String remoteFileKey,
    required List<String> clientMethods,
    int? partNumber,
    String? uploadId,
    Map<String, String>? headers,
  }) async {
    final uri = getFullPath('/api/media/get-urls');
    final body = <String, dynamic>{
      'remoteFileKey': remoteFileKey,
      'clientMethods': clientMethods,
    };

    if (partNumber != null) body['partNumber'] = partNumber;
    if (uploadId != null) body['uploadId'] = uploadId;
    if (headers != null && headers.isNotEmpty) body['headers'] = headers;

    final data = await postJson(uri, body);
    final urls = (data['urls'] as List<dynamic>? ?? [])
        .map((e) => SignedUrlBundle.fromJson(e as Map<String, dynamic>))
        .toList();

    return urls;
  }

  Uri getFullPath(String path) {
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    final base = baseUri.toString().replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$base/$normalized');
  }

  Future<Map<String, dynamic>> postJson(
    Uri uri,
    Map<String, dynamic> body,
  ) async {
    final request = await httpClient.postUrl(uri);
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(body));

    final response = await request.close();
    final text = await response.transform(utf8.decoder).join();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(text) as Map<String, dynamic>;
    }

    throw HttpException(
      'POST ${uri.path} failed (${response.statusCode}): $text',
      uri: uri,
    );
  }
}

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
