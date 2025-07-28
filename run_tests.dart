#!/usr/bin/env dart

import 'dart:io';

class TestResult {
  final bool passed;
  final bool skipped;
  final String? error;

  TestResult({required this.passed, this.skipped = false, this.error});
}

/// Test runner script that runs all available tests and provides a summary
Future<void> main(List<String> args) async {
  print('🧪 SLTT Dart Test Suite Runner\n');

  final testResults = <String, TestResult>{};
  var totalTests = 0;
  var passedTests = 0;
  var skippedTests = 0;

  print('=' * 60);

  // Test 1: Basic unit tests (should always pass)
  print('🔍 Running Basic Unit Tests...');
  final basicResult = await runTest(
    'packages/sltt_core',
    'test/basic_test.dart',
    'Basic functionality tests',
    timeout: 10,
  );
  testResults['Basic Tests'] = basicResult;
  if (basicResult.passed) passedTests++;
  if (basicResult.skipped) skippedTests++;
  totalTests++;

  // Test 2: AWS Backend tests (should always pass)
  print('\n🔍 Running AWS Backend Tests...');
  final awsResult = await runTest(
    'packages/aws_backend',
    'test/aws_backend_test.dart',
    'AWS backend structure tests',
    timeout: 10,
  );
  testResults['AWS Backend Tests'] = awsResult;
  if (awsResult.passed) passedTests++;
  if (awsResult.skipped) skippedTests++;
  totalTests++;

  // Test 3: Projects Endpoint Tests (may fail due to Isar dependencies)
  print('\n🔍 Running Projects Endpoint Tests (may fail due to DB)...');
  final projectsResult = await runTest(
    'packages/sltt_core',
    'test/projects_endpoint_test.dart',
    'Projects API endpoint tests',
    timeout: 15,
  );
  testResults['Projects Endpoint Tests'] = projectsResult;
  if (projectsResult.passed) passedTests++;
  if (projectsResult.skipped) skippedTests++;
  totalTests++;

  // Test 4: Try integration tests (may fail due to Isar)
  print('\n🔍 Running Integration Tests (may fail due to Isar setup)...');
  final integrationResult = await runTest(
    'packages/sltt_core',
    'test/integration_test.dart',
    'Storage integration tests',
    timeout: 15,
  );
  testResults['Integration Tests'] = integrationResult;
  if (integrationResult.passed) passedTests++;
  if (integrationResult.skipped) skippedTests++;
  totalTests++;

  // Test 5: Try sync manager tests (may fail due to server requirements)
  print('\n🔍 Running Sync Manager Tests (may fail due to server setup)...');
  final syncResult = await runTest(
    'packages/sltt_core',
    'test/sync_manager_test.dart',
    'Sync manager functionality tests',
    timeout: 15,
  );
  testResults['Sync Manager Tests'] = syncResult;
  if (syncResult.passed) passedTests++;
  if (syncResult.skipped) skippedTests++;
  totalTests++; // Summary
  print('\n' + '=' * 60);
  print('📊 TEST SUMMARY');
  print('=' * 60);

  for (final entry in testResults.entries) {
    final status = entry.value ? '✅ PASS' : '❌ FAIL';
    print('  ${entry.key.padRight(25)} $status');
  }

  print('\n📈 Overall Results:');
  print('  Total Tests: $totalTests');
  print('  Passed: $passedTests');
  print('  Failed: ${totalTests - passedTests}');
  print(
    '  Success Rate: ${((passedTests / totalTests) * 100).toStringAsFixed(1)}%',
  );

  if (passedTests == totalTests) {
    print('\n🎉 All tests passed! Your test structure is working perfectly.');
  } else if (passedTests > 0) {
    print('\n✅ Some tests passed! The test structure is working.');
    print('   Failed tests likely need setup (Isar library, servers, etc.)');
  } else {
    print('\n⚠️  No tests passed. Check your setup and dependencies.');
  }

  print('\n💡 To run individual test files:');
  print('   cd packages/sltt_core && dart test test/basic_test.dart');
  print('   cd packages/aws_backend && dart test test/aws_backend_test.dart');
  print(
    '   cd packages/sltt_core && dart test test/projects_endpoint_test.dart',
  );

  print('\n📚 For more info: https://dart.dev/guides/testing');
}

Future<bool> runTest(
  String workingDir,
  String testFile,
  String description,
) async {
  try {
    print('   📁 Directory: $workingDir');
    print('   📄 Test File: $testFile');
    print('   📝 Description: $description');

    final result = await Process.run('dart', [
      'test',
      testFile,
      '--reporter=compact',
    ], workingDirectory: workingDir);

    if (result.exitCode == 0) {
      print('   ✅ PASSED');
      return true;
    } else {
      print('   ❌ FAILED (Exit code: ${result.exitCode})');
      if (result.stderr.toString().isNotEmpty) {
        final stderr = result.stderr.toString().trim();
        final lines = stderr.split('\n');
        print('   📋 Error: ${lines.first}');
      }
      return false;
    }
  } catch (e) {
    print('   ❌ ERROR: $e');
    return false;
  }
}
