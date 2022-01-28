import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';

class StringResBuilder implements Builder {
  StringResBuilder(BuilderOptions options) {
    final inputDir = options.config["input_path"] as Map?;
    stringResPathMap = inputDir?.map((key, value) => MapEntry(key as String, value as String));
    genCodeDir = options.config["output_dir"] as String? ?? "lib/res_gen/";
    defaultLang = options.config["default_lang"] as String? ?? "en_US";
    assert(stringResPathMap?[defaultLang] != null, "there is no path for default language");

    if (!genCodeDir.endsWith("/")) {
      genCodeDir += "/";
    }
  }

  /// The strings resource paths for multi-language.
  /// The key is country code, the value is strings resource path.
  late final Map<String, String>? stringResPathMap;

  /// The directory for generated code
  late String genCodeDir;

  /// The default language
  late final String defaultLang;

  /// The generated code file name for string res keys.
  final String stringResKeyFileName = "string_res_key";

  @override
  Future<void> build(BuildStep buildStep) async {
    // every json file in the strings resource paths will go here, but only generate
    // code when it matches the strings resource path of default language.
    final String? defaultLangPath = stringResPathMap?[defaultLang];
    if (defaultLangPath == null) {
      return;
    }

    final inputId = buildStep.inputId;
    final messages = (json.decode(await buildStep.readAsString(inputId)) as Map)
        .cast<String, String>();

    final outputBuffer = StringBuffer('// Generated, do not edit\n');
    messages.forEach((key, value) {
      outputBuffer.writeln('const String $key = \'$value\';');
    });

    final genFile = File(genCodeDir + stringResKeyFileName + buildExtensions[inputId.extension]!.first);
    final isExist = await genFile.exists();
    if (!isExist) {
      await genFile.create(recursive: true);
    }
    await genFile.writeAsString(outputBuffer.toString());
  }

  @override
  final buildExtensions = const {
    '.json': ['.g.dart']
  };

}