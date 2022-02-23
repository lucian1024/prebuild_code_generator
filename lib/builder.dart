import 'package:build/build.dart';
import 'package:prebuild_code_generator/proto_builder.dart';

import 'string_res_builder.dart';

Builder protoBuilder(BuilderOptions options) => ProtoBuilder(options);

Builder stringResBuilder(BuilderOptions options) => StringResBuilder(options);
