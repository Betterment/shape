# ▲ Shape

A package for building forms that can be easily reused, validated, and parsed, primarily for Flutter apps.

### Table of Contents

- [▲ Shape](#-shape)
    - [Table of Contents](#table-of-contents)
    - [Summary](#summary)
    - [Usage](#usage)
    - [Migrations](#migrations)
    - [Principle](#principle)
    - [Features](#features)
      - [Access parsed values](#access-parsed-values)
      - [Automatic form error generation](#automatic-form-error-generation)
    - [Example](#example)

### Summary

This package comes in three parts:

- [**The `shape` package**](https://github.com/betterment/shape/tree/main/packages/shape/README.md) that contains the primary classes and annotations used for creating form bodies.
- [**The `shape_generator` package**](https://github.com/betterment/shape/tree/main/packages/shape_generator/README.md), which is the code generator that runs on classes annotated with `@GenerateFormBody()`.
- [**The `shape_starter_kit` package**](https://github.com/betterment/shape/tree/main/packages/shape_starter_kit/README.md), which contains a set of generic and commonly used form fields and functions for use with the `shape` package.

### Usage

First, add the `shape` package to your project's dependencies using `dart pub add` or `flutter pub add`.

```bash
dart pub add shape
```

Then, add the `shape_generator` and `build_runner` packages to your project's dev dependencies using the same CLI.

```bash
dart pub add --dev shape_generator build_runner
```

> [!NOTE]
> If these commands don't work for you, consider adding the packages manually to your `pubspec.yaml` file by placing the `shape` package under `dependencies` and the `shape_generator` and `build_runner` packages under `dev_dependencies`.

To generate a form body, in this case called `ExampleFormBody`;

1. Create an abstract class `ExampleFormBody` annotated with `@GenerateFormBody()`.
2. Add the `_$ExampleFormBodyFields` mixin.
3. Add a private empty constructor (`const ExampleFormBody._();`) and one unnamed factory that returns `_$ExampleFormBody`.

A full example might look like this:

```dart
import 'package:shape/shape.dart';
import 'package:shape_starter_kit/shape_starter_kit.dart';

part 'example_form_body.g.dart';

@GenerateFormBody()
abstract class ExampleFormBody extends FormBody with _$ExampleFormBodyFields {
  const ExampleFormBody._();

  factory ExampleFormBody({
    @FieldRequired() String? foo,
    int? bar,
  }) = _$ExampleFormBody;
}

void main() {
  final formBody = ExampleFormBody();
}
```

### Migrations

- [0.0.1 → 0.1.0](docs/migrations/0.0.1-to-0.1.0.md)

### Principle

Shape works by separating form fields, bodies, validation logic and parsing logic into separate classes.

Form bodies are a collection of form fields. The flow of data going into and coming out of a form body looks as follows:

```mermaid
flowchart TD
  classDef multipleValues fill:#f0f0f0,stroke:#000000,stroke-dasharray: 5;
  classDef classInstance fill:#eeeeff,stroke:#aaaaee
  classDef function fill:#d0efe6,stroke:#6cddbd

  raw{{Raw String values}}:::multipleValues
  fbc(Form body constructor):::function
  fbi[Form body instance]:::classInstance
  parsed{{Parsed values}}:::multipleValues
  fei[Form errors instance]:::classInstance

  raw -- "are given to" --> fbc
  fbc -- "parses fields and creates" --> fbi
  fbi -- "contains" --> parsed
  fbi -- "when calling validate() creates" --> fei
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

To run the example, run `build_runner` in [the `example` folder](https://github.com/betterment/shape/tree/main/packages/shape/example).

```shell
cd example
flutter pub run build_runner build
```

A new form body will be generated based on the contents of [`example/lib/example_form_body.dart`](https://github.com/betterment/shape/tree/main/packages/shape/example/lib/example_form_body.dart). After the code generator has completed, examine the contents of the file [`example/lib/example_form_body.g.dart`](https://github.com/betterment/shape/tree/main/packages/shape/example/lib/example_form_body.g.dart).
