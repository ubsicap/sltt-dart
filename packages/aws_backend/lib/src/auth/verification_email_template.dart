import 'dart:convert';

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
  static const String _templateContents =
      '''<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Your SLTT verification code</title>
  </head>
  <body style="margin:0; padding:0; background-color:#f4f7fb; color:#10233f; font-family:Arial, Helvetica, sans-serif;">
    <div data-plain-text="ignore" style="display:none; max-height:0; overflow:hidden; opacity:0;">
      Your SLTT verification code is {{verification_code}}.
    </div>
    <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="width:100%; border-collapse:collapse; background-color:#f4f7fb;">
      <tr>
        <td align="center" style="padding:32px 16px;">
          <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="width:100%; max-width:560px; border-collapse:separate; background-color:#ffffff; border:1px solid #d9e3f0; border-radius:18px;">
            <tr>
              <td style="padding:28px 24px 12px 24px;">
                <p style="margin:0 0 12px 0; font-size:13px; line-height:20px; font-weight:700; letter-spacing:0.08em; text-transform:uppercase; color:#42658c;">
                  SLTT
                </p>
                <h1 style="margin:0; font-size:28px; line-height:34px; font-weight:700; color:#10233f;">
                  Verify your email
                </h1>
              </td>
            </tr>
            <tr>
              <td style="padding:0 24px 8px 24px;">
                <p data-plain-text-role="paragraph" style="margin:0; font-size:16px; line-height:24px; color:#304763;">
                  Use this six-digit code to verify your email address in the app.
                </p>
              </td>
            </tr>
            <tr>
              <td align="center" style="padding:20px 24px 24px 24px;">
                <div style="display:inline-block; min-width:220px; padding:18px 24px; border:1px solid #c7d8ef; border-radius:18px; background-color:#eef4ff; text-align:center;">
                  <p style="margin:0 0 8px 0; font-size:12px; line-height:16px; font-weight:700; letter-spacing:0.08em; text-transform:uppercase; color:#5f7b9e;">
                    Verification code
                  </p>
                  <p data-plain-text-role="code" style="margin:0; font-size:34px; line-height:40px; font-weight:700; letter-spacing:0.32em; color:#0d2a57; font-family:'Courier New', Courier, monospace; text-indent:0.32em;">
                    {{verification_code}}
                  </p>
                </div>
              </td>
            </tr>
            <tr>
              <td style="padding:0 24px 16px 24px;">
                <p data-plain-text-role="paragraph" style="margin:0; font-size:16px; line-height:24px; color:#304763;">
                  This code expires <strong>{{expires_in}}</strong>.
                </p>
              </td>
            </tr>
            <tr>
              <td style="padding:0 24px 28px 24px;">
                <p data-plain-text-role="paragraph" style="margin:0 0 12px 0; font-size:16px; line-height:24px; color:#304763;">
                  For your security:
                </p>
                <ul style="margin:0; padding-left:20px; color:#304763;">
                  <li data-plain-text-role="list-item" style="margin:0 0 8px 0; font-size:15px; line-height:22px;">
                    Enter this code only in the SLTT verification screen.
                  </li>
                  <li data-plain-text-role="list-item" style="margin:0 0 8px 0; font-size:15px; line-height:22px;">
                    Do not share this code with anyone.
                  </li>
                  <li data-plain-text-role="list-item" style="margin:0; font-size:15px; line-height:22px;">
                    If you did not request this code, you can ignore this message.
                  </li>
                </ul>
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </body>
</html>
''';

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

  static Future<String> _loadTemplateContents() async => _templateContents;

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
