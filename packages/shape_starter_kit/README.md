# ⏺ Shape Starter Kit

A set of generic and commonly used form fields and functions for use with the [`shape`](https://pub.dev/packages/shape) package.

### Summary

This package comes with the following form fields for use in any application:

- `GenericFormField<T>`: A generic form field that can be used for any type of data.

### Usage

These form fields can be used in any Shape form body.

A full example might look like this:

```dart
import 'package:shape/shape.dart';
import 'package:shape_addons/shape_addons.dart';

part 'example_form_body.g.dart';

@GenerateFormBody()
abstract class ExampleFormBody with _$ExampleFormBodyFields {
  factory ExampleFormBody({
    required String? foo,
  }) {
    return _$ExampleFormBody(
      name: GenericFormField<String?>(
        value: foo,
        isRequired: true,
      ),
    );
  }
}

void main() {
  final formBody = ExampleFormBody();
}
```

### Example

An example on how to use this package can be found in the [`shape` example project](../shape/example/README.md).
