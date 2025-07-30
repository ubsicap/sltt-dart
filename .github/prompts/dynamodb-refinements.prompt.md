Fixes:
- need to normalize entityTypes
- 'project' is currently required for dynamodb implementation of returning projectIds (stored in entityId)
- maybe pk should be PROJECT_ID#{projectId}

- changeAt same as cloudAt in the cloud?

- toUtc() everywhere for consistency?


Design:
- pk is projectId. Ideally it would be something like projectId#{projectId}#entityId#{entityId} to
1) maximize write throughput (especially if many people are writing to same projectId at the same time)
2) allow for querying by entityId (and seeing all changes)

- could make secondary index on projectId sorted by seq



### 🧩 Optional Refinements

- **Streamlining Header Management**
  You could compose a `Map<String, String>` generator function for headers per target and region, making it easier to swap in other AWS services:
  ```dart
  Map<String, String> dynamoHeaders(String target, Uri uri) => {
    'Content-Type': 'application/x-amz-json-1.0',
    'X-Amz-Target': 'DynamoDB_20120810.$target',
    'host': uri.host,
  };
  ```

- **Error Modeling**
  If you prefer expressive error handling (Result-type or union modeling), wrapping the response in a custom `Result<http.Response>` might give you more declarative control over retry/backoff strategies.

- **Diagnostics**
  Logging `signedRequest.headers`, `signedRequest.uri`, and the SHA256 of `encodedBody` before sending can help during debugging — especially if you start seeing `403` or `400` responses and want to confirm what was signed.

---

This version already feels like it follows the spirit of “zero mismatches, maximum composability.” If you ever want to wrap this in a Dart service client that mirrors `DynamoDBDocumentClient` style from JS, we could sketch a layer that does encoding/decoding of payloads and ops declaratively.

Want to turn this into a shared `DynamoDBSigV4Client` class for use across functions? Or pipe the result through a pattern-matching response handler?
