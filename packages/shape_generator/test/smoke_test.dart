import 'dart:io';

import 'package:checks/checks.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart' hide expect;

const testFileDirName = 'fixtures';
const testSrcFileName = 'test_form_body.dart';
const testOutputFileName = 'test_form_body.g.dart';
const testExpectedOutputFileName = 'test_form_body.expected.txt';

Future<void> main() async {
  late Directory testDir;
  late File testSrcFile;
  late File testOutputFile;
  late File testExpectedOutputFile;

  setUpAll(() {
    testDir = Directory(p.join('test'));
    final testFileDir = Directory(p.join(testDir.path, testFileDirName));

    testSrcFile = File(p.join(testFileDir.path, testSrcFileName));
    testOutputFile = File(p.join(testFileDir.path, testOutputFileName));
    testExpectedOutputFile =
        File(p.join(testFileDir.path, testExpectedOutputFileName));

    if (!testFileDir.existsSync()) {
      throw Exception(
        "Test file directory does not exist at '${testFileDir.absolute.path}'. "
        'Create it and provide the necessary files.',
      );
    } else if (!testSrcFile.existsSync()) {
      throw Exception(
          "Test source file does not exist at '${testSrcFile.absolute.path}'."
          'Create it and provide the necessary files.');
    } else if (!testExpectedOutputFile.existsSync()) {
      throw Exception(
        'Test expected output file does not exist at '
        "'${testExpectedOutputFile.absolute.path}'."
        'Did you forget to run `dart run build_runner build`?',
      );
    }
  });

  test('smoke test (run generator and compare output)', () {
    print('Deleting output file...');
    if (testOutputFile.existsSync()) {
      testOutputFile.deleteSync();
    }

    print('Running build_runner...');
    final result = Process.runSync(
      'dart',
      [
        'run',
        'build_runner',
        'build',
        '--delete-conflicting-outputs',
        testDir.path,
      ],
    );
    if (result.exitCode != 0) {
      print(result.stdout);
      print(result.stderr);
      fail(
        'build_runner failed with exit code ${result.exitCode}',
      );
    }
    print('Done.');
    print('Output:');
    for (final line in result.stdout.toString().split('\n')) {
      print('  $line');
    }

    final testOutput = testOutputFile.readAsStringSync();
    final testExpectedOutput = testExpectedOutputFile.readAsStringSync();

    check(testOutput).equals(testExpectedOutput);
  });
}
