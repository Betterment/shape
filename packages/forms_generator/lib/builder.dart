import 'package:build/build.dart';
import 'package:forms_generator/src/generators/generators.dart';
import 'package:source_gen/source_gen.dart';

Builder forms(BuilderOptions options) =>
    SharedPartBuilder([FormsGenerator()], 'forms');
