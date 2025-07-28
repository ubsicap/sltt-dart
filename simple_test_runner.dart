#!/usr/bin/env dart

import 'dart:io';

/// Simple test runner that handles timeouts and provides clear status
Future<void> main(List<String> args) async {
  print('🧪 SLTT Test Runner - Checking working tests only\n');

  final workingTests = [
    {
      'name': 'Basic Unit Tests',
      'dir': 'packages/sltt_core',
      'file': 'test/basic_test.dart',
      'description': 'Core functionality without dependencies',
    },
    {
      'name': 'AWS Backend Tests',
      'dir': 'packages/aws_backend',
      'file': 'test/aws_backend_test.dart',
      'description': 'Backend service instantiation',
    },
  ];

  final potentialTests = [
    {
      'name': 'Projects Endpoint Tests',
      'dir': 'packages/sltt_core',
      'file': 'test/projects_endpoint_test.dart',
      'description': 'API endpoint tests (may fail due to Isar)',
    },
  ];

  var totalPassed = 0;
  var totalRun = 0;

  print('=' * 60);
  print('🟢 RUNNING WORKING TESTS (should pass)');
  print('=' * 60);

  for (final test in workingTests) {
    print('\n🔍 ${test['name']}');
    final passed = await runSingleTest(
      test['dir']!,
      test['file']!,
      test['description']!,
      timeout: 10,
    );
    if (passed) totalPassed++;
    totalRun++;
  }

  print('\n${'=' * 60}');
  print('🟡 TESTING POTENTIALLY PROBLEMATIC TESTS');
  print('=' * 60);

  for (final test in potentialTests) {
    print('\n🔍 ${test['name']}');
    final passed = await runSingleTest(
      test['dir']!,
      test['file']!,
      test['description']!,
      timeout: 15,
    );
    if (passed) totalPassed++;
    totalRun++;
  }

  print('\n${'=' * 60}');
  print('📊 FINAL SUMMARY');
  print('=' * 60);
  print('Total tests run: $totalRun');
  print('Tests passed: $totalPassed');
  print('Tests failed: ${totalRun - totalPassed}');
  print(
    'Success rate: ${((totalPassed / totalRun) * 100).toStringAsFixed(1)}%',
  );

  if (totalPassed >= 2) {
    print('\n✅ Core test structure is working!');
    print('   At least the basic tests are passing successfully.');
  } else {
    print('\n⚠️  Core tests are failing - check your setup.');
  }

  print('\n💡 To run tests individually:');
  print('   cd packages/sltt_core && dart test test/basic_test.dart');
  print('   cd packages/aws_backend && dart test test/aws_backend_test.dart');
}

Future<bool> runSingleTest(
  String workingDir,
  String testFile,
  String description, {
  int timeout = 30,
}) async {
  print('   📁 $workingDir');
  print('   📄 $testFile');
  print('   📝 $description');

  try {
    final process = await Process.start('dart', [
      'test',
      testFile,
      '--reporter=compact',
    ], workingDirectory: workingDir);

    // Set up timeout
    Timer? timeoutTimer;
    if (timeout > 0) {
      timeoutTimer = Timer(Duration(seconds: timeout), () {
        process.kill();
      });
    }

    final exitCode = await process.exitCode;
    timeoutTimer?.cancel();

    if (exitCode == 0) {
      print('   ✅ PASSED');
      return true;
    } else if (exitCode == -15 || exitCode == 143) {
      print('   ⏰ TIMEOUT (${timeout}s) - likely hanging on setup');
      return false;
    } else {
      print('   ❌ FAILED (exit code: $exitCode)');
      return false;
    }
  } catch (e) {
    print('   ❌ ERROR: $e');
    return false;
  }
}

class Timer {
  Timer(Duration duration, void Function() callback) {
    Future.delayed(duration, callback);
  }
  void cancel() {}
}
