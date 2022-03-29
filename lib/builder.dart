import 'package:build/build.dart';
import 'package:prebuild_code_generator/proto_builder.dart';

import 'image_res_builder.dart';
import 'string_res_builder.dart';

Builder protoBuilder(BuilderOptions options) => ProtoBuilder(options);

Builder stringResBuilder(BuilderOptions options) => StringResBuilder(options);

Builder imageResBuilder(BuilderOptions options) => ImageResBuilder(options);
