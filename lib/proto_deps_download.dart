import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:prebuild_code_generator/process_util.dart';

final String _builderTmpDir = path.join(".dart_tool", "build", "proto_builder");

Future<String> downloadProtoc(String protocVersion) async {
  final Directory protocTmpDir =
      Directory(path.join(_builderTmpDir, "protoc", "v$protocVersion"));

  final protoc = File(
    path.join(
        protocTmpDir.path, "bin", Platform.isWindows ? "protoc.exe" : "protoc"),
  );

  if (protoc.existsSync()) {
    return protoc.path;
  } else {
    if (!protocTmpDir.existsSync()) {
      await protocTmpDir.create(recursive: true);
    }

    Uri url = Uri.parse(
        "https://github.com/protocolbuffers/protobuf/releases/download/v$protocVersion/protoc-$protocVersion-${_getPlatform(true)}.zip");
    final archive = ZipDecoder().decodeBytes(await http.readBytes(url));
    for (final file in archive) {
      if (file.isFile) {
        final outFile = File(path.join(protocTmpDir.path, file.name));
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content);
      }
    }

    if (protoc.existsSync()) {
      if (!Platform.isWindows) {
        await ProcessUtil.runCommand("chmod", ["+x", protoc.path]);
      }
      return protoc.path;
    } else {
      throw AssertionError('protoc is not exist.');
    }
  }
}

Future<String> downloadProtocGenDart(String protocGenDartVersion) async {
  final Directory protocGenDartTmpDir = Directory(
      path.join(_builderTmpDir, "protoc_gen_dart", "v$protocGenDartVersion"));

  final protocGenDart = File(
    path.join(protocGenDartTmpDir.path, "bin",
        Platform.isWindows ? "protoc-gen-dart.bat" : "protoc-gen-dart"),
  );

  if (protocGenDart.existsSync()) {
    return protocGenDart.path;
  } else {
    if (!protocGenDartTmpDir.existsSync()) {
      await protocGenDartTmpDir.create(recursive: true);
    }

    Uri url = Uri.parse(
        "https://storage.googleapis.com/dartlang-pub-public-packages/packages/protoc_plugin-$protocGenDartVersion.tar.gz");
    final gzData = GZipDecoder().decodeBytes(await http.readBytes(url));
    final archive = TarDecoder().decodeBytes(gzData);
    for (final file in archive) {
      if (file.isFile) {
        final outFile = File(path.join(protocGenDartTmpDir.path, file.name));
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content);
      }
    }

    if (protocGenDart.existsSync()) {
      if (!Platform.isWindows) {
        await ProcessUtil.runCommand("chmod", ["+x", protocGenDart.path]);
      }
      await ProcessUtil.runCommand("dart", ["pub", "get"],
          workingDirectory: protocGenDartTmpDir.path);
      return protocGenDart.path;
    } else {
      throw AssertionError('protoc-gen-dart is not exist.');
    }
  }
}

Future<String> downloadProtocGenGrpcJava(
    String protocGenGrpcJavaVersion) async {
  final Directory _protocGenGrpcJavaTmpDir = Directory(path.join(
      _builderTmpDir, "protoc_gen_grpc_java", "v$protocGenGrpcJavaVersion"));

  final protocGenGrpcJavaName =
      "protoc-gen-grpc-java-$protocGenGrpcJavaVersion-${_getPlatform(false)}.exe";
  final protocGenGrpcJava = File(
    path.join(_protocGenGrpcJavaTmpDir.path, protocGenGrpcJavaName),
  );

  if (protocGenGrpcJava.existsSync()) {
    return protocGenGrpcJava.path;
  } else {
    if (!_protocGenGrpcJavaTmpDir.existsSync()) {
      await _protocGenGrpcJavaTmpDir.create(recursive: true);
    }

    Uri url = Uri.parse(
        "https://repo1.maven.org/maven2/io/grpc/protoc-gen-grpc-java/$protocGenGrpcJavaVersion/$protocGenGrpcJavaName");
    await protocGenGrpcJava.writeAsBytes(await http.readBytes(url));

    if (protocGenGrpcJava.existsSync()) {
      if (!Platform.isWindows) {
        await ProcessUtil.runCommand('chmod', ['+x', protocGenGrpcJava.path]);
      }

      return protocGenGrpcJava.path;
    } else {
      throw AssertionError('protoc-gen-grpc-java is not exist.');
    }
  }
}

String _getPlatform(bool isProtoc) {
  String platform;
  switch (Platform.operatingSystem) {
    case "linux":
      platform = "linux-x86_64";
      break;
    case "windows":
      platform = isProtoc ? "win64" : "windows-x86_64";
      break;
    case "macos":
      platform = "osx-x86_64";
      break;
    default:
      throw UnsupportedError('Current platform is not supported.');
  }
  return platform;
}
