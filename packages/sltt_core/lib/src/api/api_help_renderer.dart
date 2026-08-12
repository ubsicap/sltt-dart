import 'dart:convert';

Map<String, dynamic> normalizeApiHelpDocs(Map<String, dynamic> docs) {
  final endpoints =
      (docs['endpoints'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>()
          .map((endpoint) => Map<String, dynamic>.from(endpoint))
          .toList() ??
      <Map<String, dynamic>>[];

  final normalizedEndpoints = endpoints.map((endpoint) {
    if (endpoint['group'] == null) {
      endpoint['group'] = 'common';
    }
    return endpoint;
  }).toList();

  return {...docs, 'endpoints': normalizedEndpoints};
}

String renderApiHelpHtml(Map<String, dynamic> docs) {
  final server = docs['server'] as Map<String, dynamic>? ?? {};
  final endpoints =
      (docs['endpoints'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
      <Map<String, dynamic>>[];

  final groupedEndpoints = <String, List<Map<String, dynamic>>>{};
  for (final endpoint in endpoints) {
    final group =
        (endpoint['group'] as String?)?.trim().toLowerCase() ?? 'common';
    groupedEndpoints.putIfAbsent(group, () => []).add(endpoint);
  }

  final orderedGroups = <String>['common', 'custom', 'aws'];
  final groupKeys = [
    ...orderedGroups.where(groupedEndpoints.containsKey),
    ...groupedEndpoints.keys.where((k) => !orderedGroups.contains(k)),
  ];

  final buffer = StringBuffer();
  buffer.writeln('<!doctype html>');
  buffer.writeln('<html lang="en">');
  buffer.writeln('<head>');
  buffer.writeln('<meta charset="utf-8">');
  buffer.writeln(
    '<meta name="viewport" content="width=device-width,initial-scale=1">',
  );
  buffer.writeln(
    '<title>${_htmlEscape(server['name']?.toString() ?? 'API Help')}</title>',
  );
  buffer.writeln('<style>');
  buffer.writeln(
    'body{font-family:system-ui,Segoe UI,Roboto,Helvetica,Arial,sans-serif;background:#f7f9fc;color:#111;margin:0;padding:0;}',
  );
  buffer.writeln('.page{max-width:980px;margin:0 auto;padding:24px;}');
  buffer.writeln('h1,h2,h3{color:#1f3a5f;margin-top:1.6rem;}');
  buffer.writeln(
    '.endpoint{border:1px solid #dfe3ea;border-radius:10px;background:#fff;padding:18px;margin:18px 0;}',
  );
  buffer.writeln(
    '.endpoint-header{display:flex;flex-wrap:wrap;gap:.5rem;align-items:center;margin-bottom:12px;}',
  );
  buffer.writeln(
    '.method{font-weight:700;padding:.25rem .65rem;border-radius:4px;background:#0f62fe;color:#fff;font-size:.92rem;}',
  );
  buffer.writeln('.path{font-family:monospace;color:#172b4d;}');
  buffer.writeln('table{width:100%;border-collapse:collapse;margin-top:12px;}');
  buffer.writeln(
    'th,td{border:1px solid #dfe3ea;padding:10px;text-align:left;}',
  );
  buffer.writeln('th{background:#f2f4f7;}');
  buffer.writeln(
    'pre{background:#f4f6f8;padding:12px;border-radius:8px;overflow:auto;}',
  );
  buffer.writeln('code{font-family:monospace;}');
  buffer.writeln('</style>');
  buffer.writeln('</head>');
  buffer.writeln('<body><div class="page">');
  buffer.writeln(
    '<h1>${_htmlEscape(server['name']?.toString() ?? 'API Help')}</h1>',
  );
  buffer.writeln(
    '<p><strong>Storage:</strong> ${_htmlEscape(server['storageType']?.toString() ?? '')}</p>',
  );
  if (server['description'] != null) {
    buffer.writeln(
      '<p>${_htmlEscape(server['description']?.toString() ?? '')}</p>',
    );
  }

  final features = (server['features'] as List<dynamic>?) ?? const [];
  if (features.isNotEmpty) {
    buffer.writeln('<section><h2>Features</h2><ul>');
    for (final feature in features) {
      buffer.writeln('<li>${_htmlEscape(feature.toString())}</li>');
    }
    buffer.writeln('</ul></section>');
  }

  for (final group in groupKeys) {
    final endpointsForGroup = groupedEndpoints[group]!;
    buffer.writeln('<section>');
    buffer.writeln('<h2>${_htmlEscape(_apiHelpGroupLabel(group))}</h2>');
    for (final endpoint in endpointsForGroup) {
      buffer.writeln(_buildEndpointHtml(endpoint));
    }
    buffer.writeln('</section>');
  }

  buffer.writeln(
    '<footer><p>Generated ${DateTime.now().toUtc().toIso8601String()}</p></footer>',
  );
  buffer.writeln('</div></body></html>');
  return buffer.toString();
}

String _apiHelpGroupLabel(String group) {
  switch (group.toLowerCase()) {
    case 'common':
      return 'Common API endpoints';
    case 'custom':
      return 'Server-specific API extensions';
    case 'aws':
      return 'AWS-specific API extensions';
    default:
      return '${group[0].toUpperCase()}${group.substring(1)} API endpoints';
  }
}

String _buildEndpointHtml(Map<String, dynamic> endpoint) {
  final method = endpoint['method']?.toString() ?? '';
  final path = endpoint['path']?.toString() ?? '';
  final description = endpoint['description']?.toString();
  final examplePaths =
      (endpoint['examplePaths'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
      const [];
  final parameters =
      (endpoint['parameters'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
      const [];
  final requestBody = endpoint['requestBody'];
  final response = endpoint['response'];
  final errorResponses =
      (endpoint['errorResponses'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
      const [];

  final buffer = StringBuffer();
  buffer.writeln('<article class="endpoint">');
  buffer.writeln(
    '<div class="endpoint-header"><span class="method">${_htmlEscape(method)}</span><span class="path">${_htmlEscape(path)}</span></div>',
  );
  if (description != null && description.isNotEmpty) {
    buffer.writeln('<p>${_htmlEscape(description)}</p>');
  }
  if (examplePaths.isNotEmpty) {
    buffer.writeln(
      '<p><strong>Example paths:</strong> ${_htmlEscape(examplePaths.join(', '))}</p>',
    );
  }
  if (parameters.isNotEmpty) {
    buffer.writeln('<h3>Parameters</h3>');
    buffer.writeln(
      '<table><thead><tr><th>Name</th><th>Type</th><th>Required</th><th>Description</th></tr></thead><tbody>',
    );
    for (final parameter in parameters) {
      buffer.writeln(
        '<tr><td>${_htmlEscape(parameter['name']?.toString() ?? '')}</td><td>${_htmlEscape(parameter['type']?.toString() ?? '')}</td><td>${_htmlEscape((parameter['required'] == true).toString())}</td><td>${_htmlEscape(parameter['description']?.toString() ?? '')}</td></tr>',
      );
    }
    buffer.writeln('</tbody></table>');
  }
  if (requestBody != null) {
    buffer.writeln('<h3>Request body</h3>');
    buffer.writeln(
      '<pre>${_htmlEscape(const JsonEncoder.withIndent('  ').convert(requestBody))}</pre>',
    );
  }
  if (response != null) {
    buffer.writeln('<h3>Response</h3>');
    buffer.writeln(
      '<pre>${_htmlEscape(const JsonEncoder.withIndent('  ').convert(response))}</pre>',
    );
  }
  if (errorResponses.isNotEmpty) {
    buffer.writeln('<h3>Error responses</h3>');
    buffer.writeln(
      '<table><thead><tr><th>Status</th><th>Code</th><th>Description</th></tr></thead><tbody>',
    );
    for (final errorResponse in errorResponses) {
      buffer.writeln(
        '<tr><td>${_htmlEscape(errorResponse['statusCode']?.toString() ?? '')}</td><td>${_htmlEscape(errorResponse['code']?.toString() ?? '')}</td><td>${_htmlEscape(errorResponse['description']?.toString() ?? '')}</td></tr>',
      );
    }
    buffer.writeln('</tbody></table>');
  }
  buffer.writeln('</article>');
  return buffer.toString();
}

String _htmlEscape(String text) {
  return const HtmlEscape(HtmlEscapeMode.element).convert(text);
}
