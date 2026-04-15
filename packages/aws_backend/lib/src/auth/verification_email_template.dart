import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:xml/xml.dart';

class VerificationEmailContent {
  const VerificationEmailContent({
    required this.subject,
    required this.htmlBody,
    required this.textBody,
  });

  final String subject;
  final String htmlBody;
  final String textBody;
}

class VerificationEmailTemplateRenderer {
  VerificationEmailTemplateRenderer({
    Future<String> Function()? templateLoader,
    DateTime Function()? nowProvider,
  }) : _templateLoader = templateLoader ?? _loadTemplateContents,
       _nowProvider = nowProvider ?? DateTime.now;

  static const String _subject = 'Your SLTT verification code';
  static const String _templatePackageUri =
      'package:aws_backend/src/auth/templates/verification_email.template.html';
  static Future<String>? _cachedTemplateContents;

  final Future<String> Function() _templateLoader;
  final DateTime Function() _nowProvider;

  Future<VerificationEmailContent> render({
    required String code,
    required DateTime expiresAt,
  }) async {
    final template = await _templateLoader();
    final expiryDescription = _formatExpiryDescription(
      now: _nowProvider(),
      expiresAt: expiresAt,
    );
    final htmlBody = _renderHtmlBody(
      template: template,
      code: code,
      expiryDescription: expiryDescription,
    );
    final textBody = _renderTextBody(htmlBody: htmlBody);

    return VerificationEmailContent(
      subject: _subject,
      htmlBody: htmlBody,
      textBody: textBody,
    );
  }

  static Future<String> _loadTemplateContents() {
    return _cachedTemplateContents ??= () async {
      final resolvedUri = await Isolate.resolvePackageUri(
        Uri.parse(_templatePackageUri),
      );
      if (resolvedUri == null) {
        throw StateError(
          'Unable to resolve verification email template: $_templatePackageUri',
        );
      }
      return File.fromUri(resolvedUri).readAsString();
    }();
  }

  static String _renderHtmlBody({
    required String template,
    required String code,
    required String expiryDescription,
  }) {
    final htmlEscape = const HtmlEscape(HtmlEscapeMode.element);
    final rendered = template
        .replaceAll('{{verification_code}}', htmlEscape.convert(code))
        .replaceAll('{{expires_in}}', htmlEscape.convert(expiryDescription));

    final unresolvedToken = RegExp(r'\{\{[^}]+\}\}').firstMatch(rendered);
    if (unresolvedToken != null) {
      throw StateError(
        'Unresolved verification email token: ${unresolvedToken.group(0)}',
      );
    }

    return rendered;
  }

  static String _formatExpiryDescription({
    required DateTime now,
    required DateTime expiresAt,
  }) {
    final difference = expiresAt.toUtc().difference(now.toUtc());
    if (difference <= Duration.zero) {
      return 'soon';
    }

    final roundedMinutes = (difference.inSeconds / Duration.secondsPerMinute)
        .round()
        .clamp(1, 1000000);

    if (roundedMinutes == 1) {
      return 'in about 1 minute';
    }

    return 'in about $roundedMinutes minutes';
  }

  static String _renderTextBody({required String htmlBody}) {
    final document = XmlDocument.parse(htmlBody);
    final sections = <String>[_subject];
    final listItems = <String>[];

    for (final element in document.descendants.whereType<XmlElement>()) {
      final role = element.getAttribute('data-plain-text-role');
      if (role == null) {
        continue;
      }

      final text = _extractInlineText(element);
      if (text.isEmpty) {
        continue;
      }

      if (role == 'list-item') {
        listItems.add('- $text');
        continue;
      }

      if (listItems.isNotEmpty) {
        sections.add(listItems.join('\n'));
        listItems.clear();
      }

      sections.add(text);
    }

    if (listItems.isNotEmpty) {
      sections.add(listItems.join('\n'));
    }

    return sections.join('\n\n');
  }

  static String _extractInlineText(XmlNode node) {
    final pieces = <String>[];

    void visit(XmlNode current) {
      if (current is XmlText) {
        final normalized = current.value.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (normalized.isNotEmpty) {
          pieces.add(normalized);
        }
        return;
      }

      if (current is! XmlElement) {
        return;
      }

      if (current.getAttribute('data-plain-text') == 'ignore') {
        return;
      }

      for (final child in current.children) {
        visit(child);
      }
    }

    for (final child in node.children) {
      visit(child);
    }

    return pieces
        .join(' ')
        .replaceAllMapped(RegExp(r'\s+([,.;:!?])'), (match) => match.group(1)!)
        .trim();
  }
}
