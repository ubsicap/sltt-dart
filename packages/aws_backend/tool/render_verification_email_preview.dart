import 'dart:io';

import 'package:aws_backend/src/auth/verification_email_template.dart';

Future<void> main(List<String> args) async {
  final outputDirectory = args.isNotEmpty
      ? Directory(args.first)
      : Directory(
          '${Directory.current.path}${Platform.pathSeparator}tool${Platform.pathSeparator}generated',
        );
  await outputDirectory.create(recursive: true);

  final renderer = VerificationEmailTemplateRenderer(
    nowProvider: () => DateTime.utc(2026, 4, 14, 18, 20, 20),
  );
  final emailContent = await renderer.render(
    code: '123456',
    expiresAt: DateTime.utc(2026, 4, 14, 18, 30),
  );

  final htmlFile = File(
    '${outputDirectory.path}${Platform.pathSeparator}verification_email.preview.html',
  );
  final textFile = File(
    '${outputDirectory.path}${Platform.pathSeparator}verification_email.preview.txt',
  );

  await htmlFile.writeAsString(emailContent.htmlBody);
  await textFile.writeAsString(emailContent.textBody);

  stdout.writeln('Wrote ${htmlFile.path}');
  stdout.writeln('Wrote ${textFile.path}');
}
