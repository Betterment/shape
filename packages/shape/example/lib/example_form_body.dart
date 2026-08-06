import 'package:shape/shape.dart';
import 'package:shape_starter_kit/shape_starter_kit.dart';

part 'example_form_body.g.dart';

@GenerateFormBody()
abstract class ExampleFormBody extends FormBody with _$ExampleFormBodyFields {
  const ExampleFormBody._();

  factory ExampleFormBody({@FieldRequired() String? name, int? age}) =
      _$ExampleFormBody;
}
