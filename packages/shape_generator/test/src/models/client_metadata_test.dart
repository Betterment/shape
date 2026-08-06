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

class NullableFormField<T> extends FormField<T?, T?, GenericValidationError> {
  NullableFormField({required T? rawValue}) : super(rawValue);

  @override
  T? get value => rawValue;

  @override
  GenericValidationError? validate() => null;
}

enum GenericValidationError { missing }
''',
        },
        (resolver) async {
          final library = await resolver.libraryFor(
            AssetId('_resolve_source', 'lib/metadata.dart'),
          );
          final element = library.getClass('NullableFormField')!;
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

@GenerateFormBody()
abstract class SampleFormBody extends FormBody<SampleFormErrors>
    with _\$SampleFormBodyFields {
  factory SampleFormBody({required String? name}) {
    return _\$SampleFormBody(
      name: GenericFormField<String?>(name),
    );
  }

  const SampleFormBody._();
}

class GenericFormField<T> extends FormField<T, T, GenericValidationError> {
  const GenericFormField(super.rawValue);

  @override
  T get value => rawValue;

  @override
  GenericValidationError? validate() => null;
}

enum GenericValidationError { missing }
''',
        },
        (resolver) async {
          final library = await resolver.libraryFor(
            AssetId('_resolve_source', 'lib/metadata.dart'),
          );
          final element = library.getClass('SampleFormBody')!;
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
        returnStatement: null,
      );

      check(metadata.isUnnamed).isTrue();
    });

    test('treats empty constructor names as unnamed', () {
      final metadata = ClientConstructorMetadata(
        name: '',
        enclosingClass: enclosingClass,
        isFactory: true,
        returnStatement: null,
      );

      check(metadata.isUnnamed).isTrue();
    });
  });
}
