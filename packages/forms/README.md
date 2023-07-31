# forms

A package for building forms in the Betterment application, primarily used in Flutter applications.

### Summary

This package comes in three parts:

- **The `forms` package** that contains the primary classes and annotations used for creating form bodies.
- [**The `forms_generator` package**](../forms_generator/README.md), which is the code generator that runs on classes annotated with `@GenerateFormBody()`.
- [**The `flutter_forms` package**](../flutter_forms/README.md) which contains general purpose reusable form fields and input formatters.

### Usage

To generate a form body, in this case called `ExampleFormBody`;

1. Create an abstract class `ExampleFormBody` annotated with `@GenerateFormBody()`.
1. Mix in the mixin `_$ExampleFormBodyFields`.
1. Create a single unnamed factory that returns an instance of `_$ExampleFormBody` containing all form fields that should be present in the form body. All parameters must be of a type of class that extends [`FormField`](./lib/src/form_field.dart), a class provided by this package.

A full example might look like this:

```dart
import 'package:flutter_forms/flutter_forms.dart';
import 'package:forms/forms.dart';

part 'example_form_body.g.dart';

@GenerateFormBody()
abstract class ExampleFormBody with _$ExampleFormBodyFields {
  factory ExampleFormBody({
    required String? foo,
    required String? bar,
  }) {
    return _$ExampleFormBody(
      name: GenericFormField(
        value: foo,
        isRequired: true,
      ),
      otherName: RangedDoubleFormField(
        value: bar,
      ),
    );
  }
}

void main() {
  final formBody = ExampleFormBody();
}
```

### Features

#### Access parsed values

Form bodies take in raw values and produce parsed values. Whenever a form body is constructed or copied (using `copyWith`), the values are automatically parsed and accessible as properties with the same name as the original field.

```dart
var formBody = TaxFormBody(vatPercentage: null);
print(formBody.vatPercentage); // null

formBody = formBody.copyWith(vatPercentage: '0.0');
print(formBody.vatPercentage); // Percent('0%')
```

#### Automatic form error generation

When generating a form body, an adjacent [`FormErrors`] class is also created and accessible.

```dart
var formBody = TaxFormBody(vatPercentage: null);
print(formBody.validate()) // TaxFormErrors(vatPercentage: PercentValidationError.empty)

formBody = formBody.copyWith(vatPercentage: 'abc');
print(formBody.validate()) // TaxFormErrors(vatPercentage: PercentValidationError.invalid)

formBody = formBody.copyWith(vatPercentage: '2.0');
print(formBody.validate()) // TaxFormErrors(vatPercentage: null)
```

### Example

An example can be found in the [`forms_generator` package README](../forms_generator/README.md).

### Notes

The original ADR can be found [here](https://github.com/Betterment/mobile/blob/jay/forms-poc/flutter/doc/arch/adr-036.md).

```

```
