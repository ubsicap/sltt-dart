import 'dart:convert';

/// Ensures every endpoint has a `group` (defaults to 'common').
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

  // Pre-compute a stable, unique anchor id for every endpoint up front so the
  // TOC and the endpoint bodies agree on the same ids.
  final anchorIds = <Map<String, dynamic>, String>{};
  final usedAnchors = <String, int>{};
  for (final endpoint in endpoints) {
    final method = endpoint['method']?.toString() ?? '';
    final path = endpoint['path']?.toString() ?? '';
    final base = _slugify('$method-$path');
    final count = usedAnchors.update(base, (v) => v + 1, ifAbsent: () => 0);
    anchorIds[endpoint] = count == 0 ? base : '$base-$count';
  }

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
  buffer.writeln('<style>${_css}</style>');
  buffer.writeln('</head>');
  buffer.writeln('<body><div class="page">');

  // ---- Header -------------------------------------------------------
  buffer.writeln('<header>');
  buffer.writeln(
    '<h1>${_htmlEscape(server['name']?.toString() ?? 'API Help')}</h1>',
  );
  buffer.writeln(
    '<p class="storage"><strong>Storage:</strong> ${_htmlEscape(server['storageType']?.toString() ?? '')}</p>',
  );
  if (server['description'] != null) {
    buffer.writeln(
      '<p>${_htmlEscape(server['description']?.toString() ?? '')}</p>',
    );
  }
  final features = (server['features'] as List<dynamic>?) ?? const [];
  if (features.isNotEmpty) {
    buffer.writeln('<details class="features"><summary>Features</summary><ul>');
    for (final feature in features) {
      buffer.writeln('<li>${_htmlEscape(feature.toString())}</li>');
    }
    buffer.writeln('</ul></details>');
  }
  buffer.writeln('</header>');

  // ---- Table of contents ---------------------------------------------
  buffer.writeln('<nav class="toc">');
  buffer.writeln('<h2>Endpoints</h2>');
  for (final group in groupKeys) {
    final endpointsForGroup = groupedEndpoints[group]!;
    buffer.writeln(
      '<h3>${_htmlEscape(_apiHelpGroupLabel(group))}</h3>',
    );
    buffer.writeln('<ul class="toc-list">');
    for (final endpoint in endpointsForGroup) {
      final method = endpoint['method']?.toString() ?? '';
      final path = endpoint['path']?.toString() ?? '';
      final anchor = anchorIds[endpoint]!;
      buffer.writeln(
        '<li><a href="#$anchor">'
        '<span class="method ${_methodClass(method)}">${_htmlEscape(method)}</span>'
        '<code class="path">${_htmlEscape(path)}</code>'
        '</a></li>',
      );
    }
    buffer.writeln('</ul>');
  }
  buffer.writeln('</nav>');

  // ---- Endpoint sections ----------------------------------------------
  buffer.writeln('<main>');
  for (final group in groupKeys) {
    final endpointsForGroup = groupedEndpoints[group]!;
    buffer.writeln('<section id="group-${_slugify(group)}">');
    buffer.writeln('<h2>${_htmlEscape(_apiHelpGroupLabel(group))}</h2>');
    for (final endpoint in endpointsForGroup) {
      buffer.writeln(_buildEndpointHtml(endpoint, anchorIds[endpoint]!));
    }
    buffer.writeln('</section>');
  }
  buffer.writeln('</main>');

  buffer.writeln(
    '<footer><p>Generated ${DateTime.now().toUtc().toIso8601String()}</p></footer>',
  );

  // Open (and scroll to) the endpoint matching the URL's #hash on load,
  // so TOC links and shared links land on an expanded accordion item.
  buffer.writeln('<script>');
  buffer.writeln('''
(function () {
  function openHash() {
    var id = decodeURIComponent(location.hash.replace('#', ''));
    if (!id) return;
    var el = document.getElementById(id);
    if (el && el.tagName === 'DETAILS') {
      el.open = true;
      el.scrollIntoView({block: 'start'});
    }
  }
  window.addEventListener('hashchange', openHash);
  openHash();
})();
''');
  buffer.writeln('</script>');

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

String _methodClass(String method) {
  switch (method.toUpperCase()) {
    case 'GET':
      return 'method-get';
    case 'POST':
      return 'method-post';
    case 'PUT':
      return 'method-put';
    case 'DELETE':
      return 'method-delete';
    default:
      return 'method-other';
  }
}

String _buildEndpointHtml(Map<String, dynamic> endpoint, String anchorId) {
  final method = endpoint['method']?.toString() ?? '';
  final path = endpoint['path']?.toString() ?? '';
  final description = endpoint['description']?.toString();
  final examplePaths =
      (endpoint['examplePaths'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
      const [];
  final obsoletedPaths =
      (endpoint['obsoletedPaths'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
      const [];
  final parameters =
      (endpoint['parameters'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
      const [];
  final requestBody = endpoint['requestBody'];
  final response = endpoint['response'];
  final responsesList =
      (endpoint['responses'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
      const [];
  final errorResponses =
      (endpoint['errorResponses'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
      const [];
  final requiresAuth = (endpoint['security'] as List<dynamic>?)?.isNotEmpty ??
      false;

  final buffer = StringBuffer();
  buffer.writeln('<details class="endpoint" id="${_htmlEscape(anchorId)}">');
  buffer.writeln('<summary>');
  buffer.writeln(
    '<span class="method ${_methodClass(method)}">${_htmlEscape(method)}</span>'
    '<span class="path">${_htmlEscape(path)}</span>',
  );
  if (requiresAuth) {
    buffer.writeln('<span class="badge badge-auth" title="Requires authentication">🔒 auth</span>');
  }
  buffer.writeln('</summary>');
  buffer.writeln('<div class="endpoint-body">');

  if (description != null && description.isNotEmpty) {
    buffer.writeln('<p>${_htmlEscape(description)}</p>');
  }
  if (obsoletedPaths.isNotEmpty) {
    buffer.writeln(
      '<p class="note"><strong>Replaces:</strong> ${_htmlEscape(obsoletedPaths.join(', '))}</p>',
    );
  }
  if (examplePaths.isNotEmpty) {
    buffer.writeln(
      '<p class="note"><strong>Example paths:</strong> ${_htmlEscape(examplePaths.join(', '))}</p>',
    );
  }

  if (parameters.isNotEmpty) {
    buffer.writeln('<h4>Parameters</h4>');
    buffer.writeln(
      '<table><thead><tr><th>Name</th><th>Type</th><th>Required</th><th>Description</th></tr></thead><tbody>',
    );
    for (final parameter in parameters) {
      buffer.writeln(
        '<tr><td><code>${_htmlEscape(parameter['name']?.toString() ?? '')}</code></td>'
        '<td>${_htmlEscape(parameter['type']?.toString() ?? '')}</td>'
        '<td>${_htmlEscape((parameter['required'] == true).toString())}</td>'
        '<td>${_htmlEscape(parameter['description']?.toString() ?? '')}</td></tr>',
      );
    }
    buffer.writeln('</tbody></table>');
  }

  if (requestBody != null) {
    buffer.writeln(_buildSchemaSection('Request body', requestBody));
  }
  if (response != null) {
    buffer.writeln(_buildSchemaSection('Response', response));
  }

  if (responsesList.isNotEmpty) {
    buffer.writeln('<h4>Responses</h4>');
    buffer.writeln(
      '<table><thead><tr><th>Status</th><th>Description</th></tr></thead><tbody>',
    );
    for (final r in responsesList) {
      buffer.writeln(
        '<tr><td>${_htmlEscape(r['status']?.toString() ?? '')}</td>'
        '<td>${_htmlEscape(r['description']?.toString() ?? '')}</td></tr>',
      );
    }
    buffer.writeln('</tbody></table>');
    for (final r in responsesList) {
      final shape = r['shape'];
      if (shape != null) {
        buffer.writeln(
          '<details class="raw-schema"><summary>${_htmlEscape((r['status'] ?? '').toString())} response shape</summary>'
          '<pre>${_htmlEscape(const JsonEncoder.withIndent('  ').convert(shape))}</pre></details>',
        );
      }
    }
  }

  if (errorResponses.isNotEmpty) {
    buffer.writeln('<h4>Error responses</h4>');
    buffer.writeln(
      '<table><thead><tr><th>Status</th><th>Code</th><th>Description</th></tr></thead><tbody>',
    );
    for (final errorResponse in errorResponses) {
      buffer.writeln(
        '<tr><td>${_htmlEscape(errorResponse['statusCode']?.toString() ?? '')}</td>'
        '<td>${_htmlEscape(errorResponse['code']?.toString() ?? '')}</td>'
        '<td>${_htmlEscape(errorResponse['description']?.toString() ?? '')}</td></tr>',
      );
    }
    buffer.writeln('</tbody></table>');
  }

  buffer.writeln('</div>');
  buffer.writeln('</details>');
  return buffer.toString();
}

/// Renders a labeled section (e.g. "Request body" / "Response") as:
///   - a generated example JSON block (open by default)
///   - the raw JSON Schema tucked into a collapsed <details>
String _buildSchemaSection(String title, dynamic schema) {
  final buffer = StringBuffer();
  buffer.writeln('<h4>$title</h4>');

  final example = _generateExample(schema);
  if (example != null && !(example is Map && example.isEmpty)) {
    buffer.writeln('<div class="example-label">Example</div>');
    buffer.writeln(
      '<pre class="example">${_htmlEscape(const JsonEncoder.withIndent('  ').convert(example))}</pre>',
    );
  }

  buffer.writeln(
    '<details class="raw-schema"><summary>Raw JSON Schema</summary>'
    '<pre>${_htmlEscape(const JsonEncoder.withIndent('  ').convert(schema))}</pre></details>',
  );
  return buffer.toString();
}

/// Walks a (roughly) JSON-Schema-shaped map and produces a representative
/// sample value. Prefers explicit `example`/`enum` values when present.
dynamic _generateExample(dynamic schema, {int depth = 0}) {
  if (depth > 8) return null;

  // Some fields in this codebase store an already-JSON-encoded sub-schema
  // as a string (e.g. `dataJson`). Try to decode and recurse into it.
  if (schema is String) {
    try {
      final decoded = jsonDecode(schema);
      return _generateExample(decoded, depth: depth + 1);
    } catch (_) {
      return schema;
    }
  }

  if (schema is! Map) return schema;
  final map = Map<String, dynamic>.from(schema as Map);

  if (map.containsKey('example')) return map['example'];

  final enumValues = map['enum'] as List<dynamic>?;
  if (enumValues != null && enumValues.isNotEmpty) return enumValues.first;

  final type = map['type']?.toString();
  final format = map['format']?.toString();

  switch (type) {
    case 'object':
      return _generateObjectExample(map, depth);
    case 'array':
      final items = map['items'];
      return items != null ? [_generateExample(items, depth: depth + 1)] : <dynamic>[];
    case 'string':
      return _sampleStringForFormat(format, map['description']?.toString());
    case 'integer':
      return 1;
    case 'number':
      return format == 'epoch-seconds' ? 1775606400 : 1.0;
    case 'boolean':
      return false;
    default:
      // No explicit `type`; fall back to properties if present, else null
      // (rendered as "no example available", raw schema still shown).
      if (map.containsKey('properties') || map.containsKey('additionalProperties')) {
        return _generateObjectExample(map, depth);
      }
      return null;
  }
}

dynamic _generateObjectExample(Map<String, dynamic> map, int depth) {
  final properties = map['properties'] as Map<dynamic, dynamic>?;
  if (properties != null) {
    final result = <String, dynamic>{};
    properties.forEach((key, value) {
      result[key.toString()] = _generateExample(value, depth: depth + 1);
    });
    return result;
  }
  final additional = map['additionalProperties'];
  if (additional != null) {
    return {'exampleKey': _generateExample(additional, depth: depth + 1)};
  }
  return <String, dynamic>{};
}

String _sampleStringForFormat(String? format, String? description) {
  switch (format) {
    case 'ISO8601':
      return DateTime.now().toUtc().toIso8601String();
    case 'yyyy-MM-dd':
      return '2026-01-15';
    default:
      return 'string';
  }
}

String _slugify(String text) {
  final slug = text
      .toLowerCase()
      .replaceAll(RegExp(r'[{}]'), '')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return slug.isEmpty ? 'endpoint' : slug;
}

String _htmlEscape(String text) {
  return const HtmlEscape(HtmlEscapeMode.element).convert(text);
}

const String _css = '''
body{font-family:system-ui,Segoe UI,Roboto,Helvetica,Arial,sans-serif;background:#f7f9fc;color:#111;margin:0;padding:0;}
.page{max-width:1040px;margin:0 auto;padding:24px;}
h1,h2,h3,h4{color:#1f3a5f;}
h2{margin-top:2rem;border-bottom:1px solid #dfe3ea;padding-bottom:.4rem;}
h4{margin:1rem 0 .4rem;}
header p.storage{color:#445;}
details.features summary{cursor:pointer;font-weight:600;color:#1f3a5f;}

nav.toc{background:#fff;border:1px solid #dfe3ea;border-radius:10px;padding:16px 20px;margin:20px 0;}
nav.toc h2{margin-top:0;border:none;}
nav.toc h3{margin:1rem 0 .3rem;font-size:.95rem;text-transform:uppercase;letter-spacing:.03em;color:#5b6b83;}
ul.toc-list{list-style:none;margin:0 0 .5rem;padding:0;columns:2;column-gap:24px;}
ul.toc-list li{break-inside:avoid;margin:.15rem 0;}
ul.toc-list a{display:flex;gap:.5rem;align-items:center;text-decoration:none;color:#172b4d;padding:.15rem 0;}
ul.toc-list a:hover .path{text-decoration:underline;}
ul.toc-list code.path{font-family:monospace;font-size:.85rem;}

details.endpoint{border:1px solid #dfe3ea;border-radius:10px;background:#fff;margin:14px 0;overflow:hidden;}
details.endpoint > summary{list-style:none;cursor:pointer;padding:14px 18px;display:flex;gap:.6rem;align-items:center;}
details.endpoint > summary::-webkit-details-marker{display:none;}
details.endpoint > summary::before{content:"▸";color:#8a94a6;margin-right:.2rem;transition:transform .15s ease;}
details.endpoint[open] > summary::before{transform:rotate(90deg);}
details.endpoint .endpoint-body{padding:0 18px 18px;border-top:1px solid #eef1f5;}

span.method{font-weight:700;padding:.2rem .6rem;border-radius:4px;color:#fff;font-size:.82rem;letter-spacing:.02em;}
.method-get{background:#0f62fe;}
.method-post{background:#198038;}
.method-put{background:#c2740d;}
.method-delete{background:#da1e28;}
.method-other{background:#5b6b83;}
span.path{font-family:monospace;color:#172b4d;font-size:.95rem;}
.badge{font-size:.78rem;padding:.15rem .5rem;border-radius:999px;background:#f2f4f7;color:#5b6b83;margin-left:auto;}
.badge-auth{background:#fff3cd;color:#7a5b00;}

p.note{color:#5b6b83;font-size:.92rem;}
table{width:100%;border-collapse:collapse;margin:.5rem 0 1rem;}
th,td{border:1px solid #dfe3ea;padding:8px 10px;text-align:left;font-size:.92rem;}
th{background:#f2f4f7;}
.example-label{font-size:.8rem;font-weight:700;text-transform:uppercase;letter-spacing:.03em;color:#198038;margin-bottom:.25rem;}
pre{background:#f4f6f8;padding:12px;border-radius:8px;overflow:auto;font-size:.85rem;}
pre.example{border:1px solid #cdeccf;background:#f6fdf6;}
details.raw-schema{margin-top:.4rem;}
details.raw-schema summary{cursor:pointer;color:#5b6b83;font-size:.85rem;}
code{font-family:monospace;}
footer{color:#8a94a6;font-size:.85rem;margin-top:2rem;}
''';
