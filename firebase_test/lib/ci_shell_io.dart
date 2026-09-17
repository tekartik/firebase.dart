/// Support for the `run_ci.dart` scripts of the dedicated env test workflows
/// (io only).
library;

import 'dart:io';

import 'package:process_run/shell.dart';

/// Default flag set by [firebaseGithubActionEnvTestShell].
///
/// The env tests (the ones needing a private service account) are only run
/// when it is set, i.e. by their dedicated workflow (`run_ci_<name>_test.yml`)
/// through `repo_support/workflow_ci_<name>_test/tool/run_ci.dart`, and not by
/// the regular run_ci workflow.
///
/// Test side, see `shouldSkipEnvTestOnGithub` in the test setup of the
/// implementation (`tekartik_firebase_rest`, `tekartik_firebase_node`...).
const githubActionsEnvTestEnvKey = 'TEKARTIK_GITHUB_ACTIONS_ENV_TEST';

/// Shell running in [path] with [flag] (default [githubActionsEnvTestEnvKey])
/// set to `'true'` in its environment.
///
/// The environment is read from [path] (i.e. its `.local/ds_env.yaml`), so
/// that it is also available to the spawned process, needed on node where the
/// tests read the process environment.
Shell firebaseGithubActionEnvTestShell(String path, {String? flag}) {
  var shellPath = Directory(path).absolute.path;
  var current = Directory.current;
  Directory.current = shellPath;
  try {
    return Shell(
      workingDirectory: shellPath,
      environment: ShellEnvironment()
        ..vars[flag ?? githubActionsEnvTestEnvKey] = 'true',
    );
  } finally {
    Directory.current = current;
  }
}
