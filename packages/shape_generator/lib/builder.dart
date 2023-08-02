import 'package:build/build.dart';
import 'package:shape_generator/src/generators/generators.dart';
import 'package:source_gen/source_gen.dart';

/// Returns a [Builder] for the shape generator.
Builder shape(BuilderOptions options) =>
    SharedPartBuilder([ShapeGenerator()], 'shape');
