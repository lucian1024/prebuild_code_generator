import 'dart:convert';
import 'dart:io';

extension ProcessUtil on Process {
  static Future<ProcessResult> runCommand(
      String executable, List<String> arguments,
      {String? workingDirectory,
      Map<String, String>? environment,
      bool includeParentEnvironment = true,
      bool runInShell = false,
      Encoding? stdoutEncoding = systemEncoding,
      Encoding? stderrEncoding = systemEncoding}) async {
    final result = await Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
      stdoutEncoding: stdoutEncoding,
      stderrEncoding: stderrEncoding,
    );
    if (result.exitCode != 0) {
      throw ProcessError(workingDirectory, executable, arguments, result);
    }
    return result;
  }
}


class ProcessError extends Error {
  ProcessError(this.workingDirectory, this.executable, this.arguments, this.result);

  final String? workingDirectory;
  final String executable;
  final List<String> arguments;
  final ProcessResult result;

  @override
  String toString() {
    return '''
Running $executable ${arguments.join(" ")} in ${workingDirectory ?? Directory.current}
Process finished with exit code ${result.exitCode}
Error:
${result.stderr}
    ''';
  }
}
