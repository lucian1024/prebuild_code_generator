import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';
import 'package:path/path.dart' as path;
import 'package:prebuild_code_generator/process_util.dart';
import 'package:prebuild_code_generator/proto_deps_download.dart';

class ProtoBuilder implements Builder {
  ProtoBuilder(BuilderOptions options) {
    protoDir = options.config["proto_dir"] as String?;

    protocVersion = options.config["protoc_version"] as String? ?? "3.19.4";

    final dartMap = options.config["dart"] as Map?;
    if (dartMap != null) {
      dartEnable = dartMap["enable"] ?? false;
      protocGenDartVersion = dartMap["protoc_gen_dart_version"] ?? "20.0.0";
      dartOutputDir = dartMap["output_dir"] as String? ?? "lib/proto_gen/";
      if (!dartOutputDir.endsWith("/")) {
        dartOutputDir += "/";
      }
    }

    final javaMap = options.config["java"] as Map?;
    if (javaMap != null) {
      javaEnable = javaMap["enable"] ?? false;
      protocGenGrpcJavaVersion = javaMap["protoc-gen-grpc-java"] ?? "1.44.0";
      javaOutputDir = javaMap["output_dir"] as String? ?? "android/app/src/main/proto_gen/";
      if (!javaOutputDir.endsWith("/")) {
        javaOutputDir += "/";
      }
    }

    final ocMap = options.config["oc"] as Map?;
    if (ocMap != null) {
      ocEnable = ocMap["enable"] ?? false;
      ocOutputDir = ocMap["output_dir"] as String? ?? "ios/Classes/Protos/";
      if (!ocOutputDir.endsWith("/")) {
        ocOutputDir += "/";
      }
    }
  }

  late String? protoDir;

  late String protocVersion;

  late bool dartEnable;
  late String protocGenDartVersion;
  late String dartOutputDir;

  late bool javaEnable;
  late String protocGenGrpcJavaVersion;
  late String javaOutputDir;

  late bool ocEnable;
  late String ocOutputDir;

  @override
  Future<void> build(BuildStep buildStep) async {
    if ((!dartEnable && !javaEnable && !ocEnable) || protoDir == null) {
      return;
    }

    final protoc = await downloadProtoc(protocVersion);
    await Future.wait([_genDartCode(protoc, buildStep), _genJavaCode(protoc, buildStep), _genOcCode(protoc, buildStep)]);
  }

  Future<void> _genDartCode(String protoc, BuildStep buildStep) async {
    if (!dartEnable) {
      return;
    }

    final protocGenDart = await downloadProtocGenDart(protocGenDartVersion);

    final dartGenDir = Directory(dartOutputDir);
    if (!dartGenDir.existsSync()) {
      dartGenDir.create(recursive: true);
    }

    await ProcessUtil.runCommand(protoc, [
      "--plugin=protoc-gen-dart=$protocGenDart",
      "--proto_path=$protoDir",
      "--dart_out=$dartOutputDir",
      buildStep.inputId.path
    ]);
  }

  Future<void> _genJavaCode(String protoc, BuildStep buildStep) async {
    if (!javaEnable) {
      return;
    }

    final javaGenDir = Directory(path.join(javaOutputDir, "java"));
    final grpcGenDir = Directory(path.join(javaOutputDir, "grpc"));
    if (!javaGenDir.existsSync()) {
      javaGenDir.create(recursive: true);
    }

    if (!grpcGenDir.existsSync()) {
      grpcGenDir.create(recursive: true);
    }

    final protocGenGrpcJava = await downloadProtocGenGrpcJava(protocGenGrpcJavaVersion);
    await ProcessUtil.runCommand(protoc, [
      "--proto_path=$protoDir",
      "--java_out=${javaGenDir.path}",
      buildStep.inputId.path
    ]);
    await ProcessUtil.runCommand(protoc, [
      "--plugin=protoc-gen-grpc-java=$protocGenGrpcJava",
      "--proto_path=$protoDir",
      "--grpc-java_out=${grpcGenDir.path}",
      buildStep.inputId.path
    ]);
  }

  Future<void> _genOcCode(String protoc, BuildStep buildStep) async {
    if (!ocEnable) {
      return;
    }

    final ocGenDir = Directory(ocOutputDir);
    if (!ocGenDir.existsSync()) {
      ocGenDir.create(recursive: true);
    }

    await ProcessUtil.runCommand(protoc, [
      "--proto_path=$protoDir",
      "--objc_out=$ocOutputDir",
      buildStep.inputId.path
    ]);
  }

  @override
  final buildExtensions = const {
    ".proto": [".pb.dart", ".pbenum.dart", ".pbjson.dart", ".pbserver.dart"]
  };
}