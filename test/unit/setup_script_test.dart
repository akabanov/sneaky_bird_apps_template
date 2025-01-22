import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Environment variables', () {
    test('Fastlane env variables are passed to CI', () async {
      const exemptions = [
        'ITUNES_PASSWORD_PATH',
        'SENTRY_CI_TOKEN_PATH',
        'APP_STORE_CONNECT_PRIVATE_KEY_PATH',
        'CICD_GITHUB_SSH_KEY_PATH',
      ];
      var unaccounted = findFastlaneEnvVars();
      unaccounted.removeAll(exemptions);
      unaccounted.removeAll(findEnvFileEnvVars());
      unaccounted.removeAll(findSecureCodemagicEnvVars());

      expect(unaccounted, isEmpty);
    });
  });
}

Set<String> findFastlaneEnvVars() {
  var vars = findEnvVars(
      'ios/fastlane', r'^[A-Z][a-z]+file$', '\\WENV\\[(\'|")(?<name>\\w+)\\1]');
  vars.removeAll(findEnvVars('ios/fastlane', r'^[A-Z][a-z]+file$',
      '\\WENV\\[(\'|")(?<name>\\w+)\\1]\\s?='));
  return vars;
}

Set<String> findSecureCodemagicEnvVars() {
  return findEnvVars(
      '.', r'setup-codemagic.sh', r'^add_codemagic_secret "?(?<name>\w+)');
}

Set<String> findEnvFileEnvVars() {
  return findEnvVars(
      '.', r'^setup(.*\.sh)?$', r'^\s*echo "?(?<name>\w+)=.*>>\s*\.env$');
}

Set<String> findEnvVars(
    String where, String fileNamePattern, String envNamePattern) {
  var fileNameRegExp = RegExp(fileNamePattern);
  var envVarRegExp = RegExp(envNamePattern, multiLine: true);

  return Directory(where)
      .listSync()
      .whereType<File>()
      .where((f) => fileNameRegExp.hasMatch(f.uri.pathSegments.last))
      .map((f) => f.readAsStringSync())
      .expand((body) => envVarRegExp.allMatches(body))
      .map((match) => match.namedGroup('name'))
      .nonNulls
      .toSet();
}
