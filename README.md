# flutter prebuild_code_generator

This package uses [build_runner](https://github.com/dart-lang/build/tree/master/build_runner) to generate code for protobuf, image and string resources before build.

[![Pub](https://img.shields.io/pub/v/prebuild_code_generator.svg?logo=flutter&color=blue&style=flat-square)](https://pub.dev/packages/prebuild_code_generator)

## Features

- `proto_builder`: Generate dart code, java code, Object-C code for proto.
- `image_res_builder`: Generate `ImageProvider` object for image sources.
- `string_res_builder`: Generate code to load and read string resources from json file.

## Getting Started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dev_dependencies:
  ...
  build_runner: ^2.1.0
  prebuild_code_generator: <latest_version>
```

Add `build.yaml` for you flutter project, which is used to config the builders. If the builder is not configured here, it will be disabled. A sample for `build.yaml` is as following:

```yaml
targets:
  $default:
    sources:
      - $package$
      - lib/$lib$
      # Regex for the resources path
      - assets/**
      # Regex for the proto path
      - proto/**
    builders:
      prebuild_code_generator:string_res_builder:
        options:
          # The string resources path for multi-language.
          input_path:
            en: "assets/strings/strings_en.json"
            zh: "assets/strings/strings_zh.json"
          # The directory for the generated code
          output_dir: "lib/res_gen"
          # The default language used to generate the keys of the string resources.
          # It must has a corresponding configuration in [input_path].
          # The default value is "en" if not configured.
          default_lang: en
          # If set true, only the keys of the string resources will be generated. The loading code
          # for string resources will not be generated.
          only_gen_key: false
      prebuild_code_generator:proto_builder:
        options:
          # The proto directory
          proto_dir: "proto/"
          # The protoc version. see https://github.com/protocolbuffers/protobuf/releases
          protoc_version: "3.19.4"
          dart:
            # Enable to generate dart code for proto
            enable: true
            # The protoc_gen_dart version. see https://pub.dev/packages/protoc_plugin
            protoc_gen_dart_version: "20.0.0"
            # The directory for the generated dart code
            output_dir: "lib/proto_gen/"
          java:
            # Enable to generate java code for proto
            enable: true
            # The protoc-gen-grpc-java version. see https://repo1.maven.org/maven2/io/grpc/protoc-gen-grpc-java/
            protoc-gen-grpc-java: "1.44.0"
            # The directory for the generated java code
            output_dir: "android/app/src/main/proto_gen/"
          oc:
            # Enable to generate object-c code for proto
            enable: true
            # The directory for the generated object-c code
            output_dir: "ios/Classes/Protos/"
      prebuild_code_generator:image_res_builder:
        options:
          # The asset image resources directory.
          # You should also config it in pubspec.yaml, like this:
          # To add assets to your application, add an assets section, like this:
          #  assets:
          #    - assets/images/
          image_dir:
            - "assets/images/"
            - "assets/animations/"
          # The directory for the generated code
          output_dir: "lib/res_gen"
```

Put the proto and resources in the corresponding directories configured in the `build.yaml`. Then run following command to generate code:

```shell
flutter packages pub run build_runner build
```

Use the generate code in the flutter project code. For more detail, see the (example)[https://github.com/lucian1024/prebuild_code_generator/tree/main/example]

```dart
import 'package:example/res_gen/image_res.g.dart';
import 'package:example/res_gen/string_res.g.dart';
import 'package:example/res_gen/string_res_key.g.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /// Load string resources.
  await StringRes.getInstance().load();
  runApp(MyApp());
}

...

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              StringRes.getString(StringResKey.ok),
            ),
            Text(
              StringRes.getString(StringResKey.hello, params: ["jack"]),
            ),
            Image(
              image: Assets.images.checkbtnChecked,
              width: 40,
              height: 40,
            ),
            Image(
              image: Assets.images.close,
              width: 40,
              height: 40,
            ),
            Image(
              image: Assets.animations.refreshLoading,
              width: 40,
              height: 40,
            )
          ],
        ),
      ),
    );
  }
}
```
