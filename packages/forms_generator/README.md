# forms_generator

A forms code generator for in the Betterment application.

This package generates code for form bodies and errors based on annotations provided by the [`forms` package](../forms/README.md).

### Usage

See the [`forms` package README](../forms/README.md) for usage instructions.

### Example

To run the example, run `build_runner` in the example folder.

```shell
cd example
flutter pub run build_runner build --delete-conflicting-outputs
```

A new form body will be generated based on the contents of [`example/lib/form_bodies/example_form_body.dart`](./example/lib/form_bodies/example_form_body.dart). After the code generator has completed, examine the contents of the file [`example/lib/form_bodies/example_form_body.g.dart`](./example/lib/form_bodies/example_form_body.g.dart).
