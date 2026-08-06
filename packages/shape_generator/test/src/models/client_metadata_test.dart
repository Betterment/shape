import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:checks/checks.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shape_generator/src/extensions/extensions.dart';
import 'package:shape_generator/src/models/client_class_metadata.dart';
import 'package:shape_generator/src/models/client_constructor_metadata.dart';
import 'package:test/test.dart' hide expect;

import '../../support/shape_generator_test_harness.dart';

class MockInterfaceType extends Mock implements InterfaceType {}

void main() {
  group('ClientClassMetadata.fromElement', () {
    test('reads type parameters from generic classes', () async {
      await resolveSources(
        {
          '_resolve_source|lib/metadata.dart': '''
import 'package:shape/shape.dart';

class NullableFormField<T> extends SimpleFormField<T?, GenericValidationError> {
  NullableFormField({required T? rawValue}) : super(rawValue);

  @override
  GenericValidationError? validate() => null;
}

enum GenericValidationError { missing }
''',
        },
        (resolver) async {
          final LibraryElement library = await resolver.libraryFor(
            AssetId('_resolve_source', 'lib/metadata.dart'),
          );
          final ClassElement element = library.getClass('NullableFormField')!;
          final metadata = ClientClassMetadata.fromElement(element);

          check(metadata.typeParameters).length.equals(1);
          check(metadata.typeParameters.first.name).equals('T');
          check(metadata.name).equals('NullableFormField<T>');
        },
        packageConfig: await workspacePackageConfigForTests(),
        readAllSourcesFromFilesystem: true,
      );
    });

    test('filters implicit default constructors', () async {
      await resolveSources(
        {
          '_resolve_source|lib/metadata.dart': '''
import 'package:shape/shape.dart';
import 'package:shape_starter_kit/shape_starter_kit.dart';

@GenerateFormBody()
abstract class SampleFormBody extends FormBody with _\$SampleFormBodyFields {
  const SampleFormBody._();

  factory SampleFormBody({@FieldRequired() String? name}) =>
      _\$SampleFormBody(name: name);
}
''',
        },
        (resolver) async {
          final LibraryElement library = await resolver.libraryFor(
            AssetId('_resolve_source', 'lib/metadata.dart'),
          );
          final ClassElement element = library.getClass('SampleFormBody')!;
          final metadata = ClientClassMetadata.fromElement(element);

          check(
            metadata.constructors.every(
              (constructor) => !constructor.isOriginImplicitDefault,
            ),
          ).isTrue();
          check(metadata.constructors.any((c) => c.isFactory)).isTrue();
        },
        packageConfig: await workspacePackageConfigForTests(),
        readAllSourcesFromFilesystem: true,
      );
    });
  });

  group('ClientConstructorMetadata', () {
    late InterfaceType enclosingClass;

    setUp(() {
      enclosingClass = MockInterfaceType();
      when(() => enclosingClass.nonNullableDisplayString).thenReturn('Foo');
    });

    test('treats unnamed constructors as new', () {
      final metadata = ClientConstructorMetadata(
        name: 'new',
        enclosingClass: enclosingClass,
        isFactory: true,
        returnExpression: null,
        redirectTarget: null,
      );

      check(metadata.isUnnamed).isTrue();
    });

    test('treats empty constructor names as unnamed', () {
      final metadata = ClientConstructorMetadata(
        name: '',
        enclosingClass: enclosingClass,
        isFactory: true,
        returnExpression: null,
      );

      check(metadata.isUnnamed).isTrue();
    });
  });
}
